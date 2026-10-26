# Video pipeline

## Data flow

```
iPhone --(AirPlay mirror, encrypted)--> uxplay
uxplay --(rtph264pay ! udpsink 127.0.0.1:$VPORT)--> app GStreamer pipeline
app pipeline:
  udpsrc port=$VPORT caps="application/x-rtp,media=video,encoding-name=H264,payload=96"
  ! rtpjitterbuffer latency=20
  ! rtph264depay
  ! h264parse
  ! <decoder>
  ! videoconvert
  ! video/x-raw,format=RGBA
  ! appsink name=mirror emit-signals=true max-buffers=2 drop=true
appsink new-sample -> copy buffer into FlPixelBufferTexture -> texture-registry mark frame
Flutter: Texture(textureId) inside the mirror widget
```

Two decode paths, selected at runtime:

1. `decodebin` (autodetect: vaapih264dec / nvdec / v4l2 on hw, avdec_h264
   fallback). Default.
2. `avdec_h264 max-threads=4` forced via a "software decode" toggle, matching
   uxplay's `-avdec` equivalent on our side.

## Latency budget

Target: under 120 ms glass to glass. Breakdown estimate:

| Stage | ms |
|---|---|
| iPhone encode + send | 25-50 (fixed, Apple) |
| uxplay depay + repayload | <5 |
| RTP loopback | <1 |
| rtpjitterbuffer (20ms setting) | up to 20 |
| decode (hw) | 10-25 |
| texture copy + Flutter raster | 8-16 |

Notes:

- `sync=false async=false` on the uxplay udpsink side: no clock discipline on
  the forward, we are the only consumer.
- `rtpjitterbuffer latency=20` is deliberately small; AirPlay RTP is mostly
  well-ordered on LAN. Raise to 40-60 only if artifacts show on congested wifi.
- appsink `drop=true max-buffers=2`: always render the newest frame, never
  backlog. Latency beats smoothness for a control surface.
- The texture path copies one RGBA frame per render. At 1080p60 that is ~500
  MB/s of memcpy, fine. A zero-copy path via `FlTextureGL` +
  `glupload`/`gldownload` is a documented v2 optimization, not v1.

## The Flutter texture bridge (the only C we write)

Flutter Linux plugins register a `FlTexture` with
`fl_texture_registrar_register_texture`. Implementation shape:

```c
struct _MirrorTexture {
  FlPixelBufferTexture parent;
  uint8_t *pixels;        // owned copy of latest frame
  size_t len;
  int width, height;
  GMutex lock;
};
```

- Plugin init: build the GStreamer pipeline via `gst_parse_launch`, attach to
  `appsink`'s `new-sample` signal.
- `new-sample` handler: `gst_app_sink_pull_sample`, map buffer, memcpy into
  `pixels` under lock, record caps width/height, call
  `fl_texture_registrar_mark_texture_frame_available`.
- `copy_pixels` virtual: return our buffer under lock.
- Channel `mirror/channel`: `start(port)`, `stop()`, `dimensions()`.

Total size estimate: 300-500 lines of C plus the method-channel boilerplate the
Flutter plugin template generates.

## Coordinate mapping (matters for input)

The absolute HID report (doc 04) takes 0..32767 x/y across the whole phone
screen. The video may be pillarboxed inside our widget. Mapping:

```
phone_x = (pointer_x - image_left) / image_width   // clip 0..1
phone_y = (pointer_y - image_top)  / image_height
hid_x   = round(phone_x * 32767)
hid_y   = round(phone_y * 32767)
```

`image_left/top/width/height` come from the same letterbox math the `Texture`
widget uses (BoxFit.contain on the reported video WxH). iPhones stream near
19.5:9; window is usually wider -> pillarbox on the sides. Clicks in the black
bars are ignored, not clamped.

## Resolution and aspect

- Advertised mode `-s 1920x1080@60`: the iPhone letterboxes its own screen into
  the stream. iOS pads to the advertised aspect, so a 1080p stream from a
  19.5:9 phone arrives with black bars baked in unless the phone supports the
  exact mode. Empirically the modern iPhones send a centered image; the true
  active rect is reported in the stream's `width/height` params early in the
  session. If the baked-in bars hurt, v2 can advertise a portrait mode
  (`-s 1080x1920` style) and test which modes iOS honors.
- Orientation changes mid-stream are normal (rotate the phone). GStreamer caps
  change -> texture resizes -> letterbox math updates. Must be tested, not
  assumed.

## Audio

v1: uxplay renders audio itself through its own `-as` audiosink (PulseAudio/
PipeWire). Our window is video-only; mute/volume is the system mixer.

v2 option: `-artp "rtpL16pay ! udpsink port=$APORT"` then
`udpsrc ! rtpL16depay ! audioconvert ! pulsesink` in-process, for a volume
slider and per-app mute.

## Failure cases to design for

- udpsrc bound but no packets (uxplay -vrtp typo, port clash): no frames after
  3 s -> show "stream not arriving" state, not a black widget.
- Decoder missing (no avdec, no hw): `gst_parse_launch` fails at startup ->
  actionable error naming the missing gst package.
- Mid-stream caps change (rotation): handled by re-allocating the pixel buffer
  on caps-change.
- Two phones at once: uxplay accepts one mirror client; second connection is
  queued/rejected depending on flags. UI shows "in use by X".
