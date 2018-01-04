# Short video recording demo

![demo.gif](https://raw.githubusercontent.com/ibubue/BPShortVideoSample/master/demo.gif)

## Features

* [x] Short video recording
* [x] Record real-time beauty, filters
* [x] Recording breakpoint continuous shooting, multi-stage synthesis
* [x] Record background music in real time
* [x] Edit Add Dynamic Face Sticker
* [x] Multi-video synthesis
* [x] Multi-track synthesis
* [x] File preview playback after upload
* [x] Video transcoding

## face, dynamic stickers formatting instructions
Sticker resources using zip packing compression, json file configuration, the configuration format is as follows:
```
{
    "fixed_stickers": [
        {
            "sticker_directory": "flower",
            "filename_format": "flower_%zd",
            "frame_count": 100,
            "positionX": 0.5,
            "positionY": 1,
            "anchorpointX": 0.5,
            "anchorpointY": 1,
            "width": 540,
            "height": 200,
            "animation_duration": 5,
            "display_width": 1,
            "display_height": 0
        }
    ],
    "face_stickers": [
        {
            "sticker_directory": "cap",
            "filename_format": "cap_%zd",
            "frame_count": 25,
            "face_type": "head",
            "width": 330,
            "height": 220,
            "animation_duration": 3
        }
    ]
}

```
Type | Parameter Name | Description
--- | --- | ---
Sticker / Face Sticker | sticker_directory | Sticker Resources directory
Fixed stickers / face stickers | filename_format | name formatting
Fixed stickers / face stickers | frame_count | number of frames
Fixed stickers | positionX | coordinate value x (value 0 ~ 1)
Fixed stickers | positionY | Coordinate value y (value 0 ~ 1)
Fixed Sticker | anchorpointX | Anchor x (Value 0 ~ 1)
Fixed Sticker | anchorpointY | Anchor y (Value 0 ~ 1)
Fixed Sticker / Face Sticker | width | Original Sticker Width
Fixed stickers / face stickers | height | sticker original height
Fixed stickers | display_width | Relative width of the display width of the screen (0 is automatic)
Fixed stickers | display_height | Display height relative to screen height (0 for auto)
Fixed Stickers / Face Stickers | animation_duration | How long to complete one animation
Face Sticker | face_type | Face Recognition Type (face, nose, head, mouth)

# 短视频录制demo
![demo.gif](https://raw.githubusercontent.com/ibubue/BPShortVideoSample/master/demo.gif)

## 功能特性

* [x] 短视频录制
* [x] 录制实时美颜，滤镜
* [x] 录制断点续拍、多段合成
* [x] 录制实时添加背景音乐
* [x] 编辑添加动态人脸贴纸
* [x] 多视频合成
* [x] 多轨道合成
* [x] 上传后文件预览播放 
* [x] 视频转码
* [x] 自己制作人脸贴纸、动态贴纸


## 人脸、动态贴纸制作格式说明
贴纸资源采用zip打包压缩制作，json文件配置，配置格式如下：

```
{
    "fixed_stickers": [
        {
            "sticker_directory": "flower",
            "filename_format": "flower_%zd",
            "frame_count": 100,
            "positionX": 0.5,
            "positionY": 1,
            "anchorpointX": 0.5,
            "anchorpointY": 1,
            "width": 540,
            "height": 200,
            "animation_duration": 5,
            "display_width": 1,
            "display_height": 0
        }
    ],
    "face_stickers": [
        {
            "sticker_directory": "cap",
            "filename_format": "cap_%zd",
            "frame_count": 25,
            "face_type": "head",
            "width": 330,
            "height": 220,
            "animation_duration": 3
        }
    ]
}

```

 类型 |参数名称| 说明
---|---|---
固定贴纸/人脸贴纸 | sticker_directory | 贴纸资源所在目录
固定贴纸/人脸贴纸 | filename_format | 名称格式化
固定贴纸/人脸贴纸 | frame_count | 帧数
固定贴纸 | positionX | 坐标值x（取值0~1）
固定贴纸 | positionY | 坐标值y（取值0~1）
固定贴纸 | anchorpointX | 锚点x（取值0~1）
固定贴纸 | anchorpointY | 锚点y（取值0~1）
固定贴纸/人脸贴纸 | width | 贴纸原始宽度
固定贴纸/人脸贴纸 | height | 贴纸原始高度
固定贴纸 | display_width | 相对屏幕宽度的展示宽度（0为自动）
固定贴纸 | display_height | 相对屏幕高度的展示高度（0为自动）
固定贴纸/人脸贴纸 | animation_duration | 完成一次动画的时长
人脸贴纸 | face_type | 人脸识别类型(face、nose、head、mouth)


