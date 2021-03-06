## 调试

当开启了Start的debug功能，你可以直接在游戏界面上读取到一些有用的信息：

- FPS（帧率）

  - 代表游戏中运行的帧率，一般为60；在HTML5中会遵循浏览器的帧率比，因此一般会为60。如果该值下降，意味着游戏的性能遇到了瓶颈，性能不够支撑游戏时，就会导致帧率下降。

- 内存使用量

  - 请注意该值，在IOS、Android中使用时，该值是相对真实的，在HTML5中的参考价值不高。

- DrawCall（绘画次数）

  - 代表实时渲染调用渲染接口的次数，该数值越低越好，游戏一般需要控制在1 - 30之间，最好能在20以下，这样能够有效确保可以在HTML5运行效果良好。

    ```xml
    <!-- 需要使用DrawCall计数器时，需要 -->
    <haxedef name="gl_stats"/>
    ```

- Updates

  - 代表框架中使用setFrameEvent的对象数量，如果值只会增加，请注意是否在不再需要的时候，没有`setFrameEvent(false);`。

- TextureCount

  - 纹理数量，理论上一个显示图像，都需要申请一个纹理；包含文本，都会占用一个纹理的数量。如果纹理持续增加，但却不会减少，说明可能存在纹理泄露，在小游戏平台该现象是非常明显的，会直接导致黑屏闪退的情况，该参数仅在HTML5中显示。

- SUpdate

  - 代表使用批渲染的Spine的FrameEvent事件对象，不同的是，批渲染对象的FrameEvent需要手动停止，否则容易造成内存泄露。

