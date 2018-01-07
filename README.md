# 短视频录制demo

抖音、快手、火山小视频等一系列 App使短视频录制已经成功热门的功能。阿里云短视频 SDK、趣拍云 SDK、涂图 SDK、七牛短视频 SDK等市面上的短视频 SDK 均收费昂贵。

## 功能特性

* [x] 短视频录制
* [x] 不含第三方收费 SDK，使用 GPUImage 开源框架和科大讯飞免费的离线人脸识别 SDK开发
* [x] 支持延迟拍摄、录制中拍照、切换摄像头
* [x] 仿全民 K 歌，原唱伴唱切换，歌词滚动显示
* [x] 录制实时美颜，滤镜可调节参数、强弱程度
* [x] 实时切换背景音乐、调整音量
* [x] 音视频分离录制，防止黑屏
* [x] 录制断点续拍、多段合成(可实现回删功能)
* [x] 实时添加动态固定或人脸贴纸
* [x] 多视频合成
* [x] 多轨道合成
* [x] 上传后文件预览播放 
* [x] 视频转码便于网络传输
* [x] 自己制作人脸贴纸、动态贴纸，png 序列帧配合 json配置 文件打包(可自主实现加密)，简单易懂

## 操作界面

![demo.gif](https://raw.githubusercontent.com/ibubue/BPShortVideoSample/master/demo.gif)

## 录制效果

![product_demo.gif](https://raw.githubusercontent.com/ibubue/BPShortVideoSample/master/product_demo.gif)


## 人脸、动态贴纸制作格式简单说明

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


