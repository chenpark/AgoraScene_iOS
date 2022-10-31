## AgoraChatDemo


## 架构设计

### **APP**

#### 1.0 主要包含图片，国际化文件，资源配置


### **Business**

#### 2.0 LoginService 登录注册服务

#### 2.1 VoiceChat2.0 语聊房业务

#### 2.2 roomService 房间列表相应的业务


### **Compoment**

#### 3.0 IM相关的业务

#### 3.1 AgoraRtcKit rtc SDK的功能封装



### **Comnon** 
#### 4.1 基础组件和公用model，类的拓展

### 使用指南

1.在loginService的LauchViewController需要配置IM Key和host，这个麻烦联系对接的声网同事获取

2.在AgoraSceneConfig的rtcId需要配置，ID的获取同样联系声网同事获取
