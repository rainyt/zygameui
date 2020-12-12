package zygame.components;

import zygame.components.ZScroll;
import openfl.display.DisplayObject;
import zygame.components.base.ItemRender;
import zygame.components.base.DefalutItemRender;
import zygame.components.layout.ListLayout;
import zygame.components.data.ListData;
import openfl.events.TouchEvent;

/**
 * 经过优化的列表
 * 每个item组件高度或者宽度都是固定的，但是你可以存放100000+的数据也不会感觉到卡顿。
 * 使用该组件，你需要配合ItemRender得到自定义渲染结构。然后将你的渲染对象赋值到itemRenderType中，使全局都使用该渲染对象。
 * 可以修改ListLayout布局的方向实现，得到横向的List。
 */
class ZList extends ZScroll
{

    /**
     * 间隔
     */
    public var gap:Int = 0;

    /**
     *  渲染池
     */
    private var _itemRenders:Array<ItemRender>;

    /**
     *  指定渲染组件
     */
    public var itemRenderType:Class<ItemRender>;

    /**
     * 当前选择渲染的组件
     */
    public var currentSelectItem:Dynamic;

    /**
     * 是否做缓存处理，这种比较适合用于文字更改频繁的页面。
     */
    public var cache:Bool = false;
    
    public function new()
    {
        super();
    }

    override public function initComponents():Void
    {
        super.initComponents();
        var layout2:ListLayout = new ListLayout();
        this.hscrollState = "off";
        view.layout = layout2;
        this.updateComponents();
        _itemRenders = [];
    }

    override public function onTouchEnd(touch:TouchEvent):Void
    {
        super.onTouchEnd(touch);
        if(Std.is(touch.target,itemRenderType) && getIsMoveing() == false && currentSelectItem != cast(touch.target,ItemRender).data)
        {
            currentSelectItem = cast(touch.target,ItemRender).data;
            this.updateAll();
            this.dispatchEvent(new openfl.events.Event(openfl.events.Event.CHANGE));
        }
    }

    override private function set_dataProvider(data:Dynamic):Dynamic
    {
        if(!Std.is(data,ListData) && data != null)
            throw "ZList对象只允许使用ListData数据，请使用ListData数据进行设置。";
        super.dataProvider = data;
        updateAll();
        return data;
    }

    public function updateAll():Void
    {
        if(!cache)
        {
            while(view.childs.length > 0){
                removeItemRender(cast view.childs[0],true);
            }
        }
        this.updateComponents();
    }

    override public function updateComponents():Void
    {
        //刷新容器布局，ZList布局只可以使用ListLayout布局对象
        if(view != null){
            if(Std.is(view.layout,ListLayout))
                view.updateComponents();
            else
                throw "ZList只可以使用ListLayout布局对象，ZList在被创建出来那一刻默认就是ListLayout布局。";
        }
    }

    /**
     *  ZList中禁用addChild方法
     *  @param display - 
     *  @return DisplayObject
     */
    override public function addChild(display:DisplayObject):DisplayObject
    {
        return this.addChildAt(display,0);
    }

    /**
     *  ZList中禁用addChild方法
     *  @param display - 
     *  @param index - 
     *  @return DisplayObject
     */
    override public function addChildAt(display:DisplayObject,index:Int):DisplayObject
    {
        throw "ZList是一个列表组件，无法直接添加对象，请使用dataProvider进行管理列表";
        return null;
    }

    /**
     *  创建ItemRender对象，这里会做垃圾池循环利用
     *  @param value 创建的对象
     *  @return ItemRender
     */
    public function createItemRender(value:Dynamic):ItemRender
    {
        if(_itemRenders.length > 0){
            for (render in _itemRenders) {
                if(render.data == value)
                {
                    _itemRenders.remove(render);
                    return render;
                }
            }
            return _itemRenders.shift();
        }
        var item:ItemRender = null;
        if(itemRenderType != null)
            item = Type.createInstance(itemRenderType,[]);
        else
            item = new DefalutItemRender();
        if(cast(this.layout,ListLayout).direction == ListLayout.VERTICAL)
            item.width = this.width;
        else
            item.height = this.height;
        return item;
    }

    /**
     *  安全移除ItemRender并放入垃圾池
     *  @param item
     */
    public function removeItemRender(item:ItemRender,clearData:Bool = false):Void
    {
        if(item != null && item.parent != null){
            if(!cache)
            {
                _itemRenders.push(item);
                view.removeChildSuper(item);
                if(item.tileDisplayObject != null)
                {
                    //批渲染对象不为空时，请清理
                    batch.getBatchs().removeTile(item.tileDisplayObject);
                }
            }
            if(clearData)
                item.data = null;
        }
    }

    override public function onFrame():Void
    {
        super.onFrame();
        if(_vMoveing || _hMoveing)
            view.updateComponents();
    }

    public function addChildSuper(item:ItemRender):Void
    {
        super.addChild(item);
        if(item.tileDisplayObject != null)
        {
            //批渲染对象不为空时，请清理
            batch.getBatchs().addChild(item.tileDisplayObject);
        }
    }
}