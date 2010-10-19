//ListBox.js
//Version: 1.0
//This script is created by Samir Nigam. Do not remove, modify, or hide the author information. keep it intact.
//Mail: nigam.samir@hotmail.com

function ListBox(Arguments)
{
    //Public property Version.
    this.Version = '1.0';
	
	//Local variables.
    var Ids = 0;
    var EventHandlers = new Array();
	
	var Base = Arguments.Base ? Arguments.Base : document.documentElement;
	var Size = !Arguments.Rows && Arguments.Rows > 5 ? Arguments.Rows : 6;	
	var Width = Arguments.Width ? Arguments.Width : 300;
	var NormalItemColor = Arguments.NormalItemColor ? Arguments.NormalItemColor : 'Black';
	var NormalItemBackColor = Arguments.NormalItemBackColor ? Arguments.NormalItemBackColor : '#ffffff';
	var AlternateItemColor = Arguments.AlternateItemColor ? Arguments.AlternateItemColor : 'Black';
	var AlternateItemBackColor = Arguments.AlternateItemBackColor ? Arguments.AlternateItemBackColor : '#E0E0E0';
	var SelectedItemColor = Arguments.SelectedItemColor ? Arguments.SelectedItemColor : '#ffffff';
	var SelectedIItemBackColor = Arguments.SelectedIItemBackColor ? Arguments.SelectedIItemBackColor : '#E6A301';
	var HoverItemColor = Arguments.HoverItemColor ? Arguments.HoverItemColor : '#ffffff';
	var HoverItemBackColor = Arguments.HoverItemBackColor ? Arguments.HoverItemBackColor : '#2259D7';
	var HoverBorderdColor = Arguments.HoverBorderdColor ? Arguments.HoverBorderdColor : 'orange';
	var ClickEventHandler = Arguments.ClickEventHandler ? Arguments.ClickEventHandler : function(){ }; 
 
	//Create div for list box.
    var ListBoxDiv = document.createElement('div');
	ListBoxDiv.style.backgroundColor = '#ffffff';
    ListBoxDiv.style.textAlign = 'left';
    ListBoxDiv.style.verticalAlign = 'top';
    ListBoxDiv.style.cursor = 'default';
    ListBoxDiv.style.borderStyle = 'inset';
    ListBoxDiv.style.overflow = 'auto';
    ListBoxDiv.style.width = Width + 'px';
	ListBoxDiv.style.height = (Size * 22) + 'px';
	
    this.AddItem = function(_Text, _Value)
	{
        var Item = null;
		var CheckBox = null;        
        var Span = null;
		
        Item = document.createElement('div');        
        Item.style.backgroundColor = Ids % 2 == 0 ? NormalItemBackColor : AlternateItemBackColor;
        Item.style.color = Ids % 2 == 0 ? NormalItemColor : AlternateItemColor;;
	    Item.style.fontWeight = 'normal';
	    Item.style.fontFamily = 'Verdana';
	    Item.style.fontSize = '10pt';
        Item.style.textAlign = 'left';
        Item.style.verticalAlign = 'middle'; 
        Item.style.cursor = 'default';
        Item.style.borderTop = Ids % 2 == 0 ? '1px solid ' + NormalItemBackColor : '1px solid ' + AlternateItemBackColor;
        Item.style.borderBottom = Ids % 2 == 0 ? '1px solid ' + NormalItemBackColor : '1px solid ' + AlternateItemBackColor;
        Item.style.overflow = 'hidden';
        Item.style.textOverflow = 'ellipsis';
		Item.ItemIndex = Ids;
		
        CheckBox = document.createElement('input');
        CheckBox.type = 'checkbox';
        Item.appendChild(CheckBox);
			
        Span = document.createElement('span');
        Span.innerHTML = _Text;     
		Span.value = _Value;     
        Span.title = _Text;     
	    Item.appendChild(Span);
	    
	    ListBoxDiv.appendChild(Item);
		
	    //Register events.
	    WireUpEventHandler(Item, 'mouseover', function(){ OnMouseOver(CheckBox, Item); });
	    WireUpEventHandler(Item, 'mouseout', function(){ OnMouseOut(CheckBox, Item); });
	    WireUpEventHandler(Item, 'selectstart', function(){ return false; });
	    WireUpEventHandler(CheckBox, 'click', function(){ OnClick(CheckBox, Item); });
	    WireUpEventHandler(CheckBox, 'click', function(){ ClickEventHandler(CheckBox, { IsSelected: CheckBox.checked, Text: _Text, Value: _Value, ItemIndex: Item.ItemIndex }); });   
	    
	    Ids++;
	}
	
    //Public method GetItems.
    this.GetItems = function()
	{
        var Items = new Array();
		
		var Divs = ListBoxDiv.getElementsByTagName('div');
		
        for(var n = 0; n < Divs.length; ++n)    
			Items.push({IsSelected: Divs[n].childNodes[0].checked, Text: Divs[n].childNodes[1].innerHTML, Value: Divs[n].childNodes[1].value, ItemIndex: Divs[n].ItemIndex});  
       		
        return Items;
    }
	
    //Public method Dispose.
	this.Dispose = function()
	{
	    while(EventHandlers.length > 0)
	        DetachEventHandler(EventHandlers.pop());
			
	    Base.removeChild(ListBoxDiv);
	}
	
	//Public method Contains.
	this.Contains = function(Index)
	{
		return typeof(Index) == 'number' && ListBoxDiv.childNodes[Index] ? true : false;
	}
	
	//Public method GetItem.
	this.GetItem = function(Index)
	{	    
	    var Divs = ListBoxDiv.getElementsByTagName('div');
		
	    return this.Contains(Index) ? { IsSelected: Divs[Index].childNodes[0].checked, Text: Divs[Index].childNodes[1].innerHTML, Value: Divs[Index].childNodes[1].value, ItemIndex: Index} : null;
	}
	
	//Public method DeleteItem.
	this.DeleteItem = function(Index)
	{
	    if(!this.Contains(Index)) return false;
	    
	    try
	    {
			ListBoxDiv.removeChild(ListBoxDiv.childNodes[Index]);
	    }
	    catch(err)
	    {
			return false;
	    }
	    
	    return true;
	}
	
	//Public method DeleteItems.
	this.DeleteItems = function()
	{
	    var ItemsRemoved = 0;
	    
	    for(var n = ListBoxDiv.childNodes.length - 1; n >= 0; --n)   
	        try
	        {
				ListBoxDiv.removeChild(ListBoxDiv.childNodes[n]);
				ItemsRemoved++;
	        }
	        catch(err)
	        {
			    break;
	        }
	        
	   return ItemsRemoved;
	}
	
	//Public method GetTotalItems.
	this.GetTotalItems = function()
	{
	    return ListBoxDiv.childNodes.length;
	}
	
    //Item mouseover event handler.
    var OnMouseOver = function(CheckBox, Item)
    {
        if(CheckBox.checked) return;
				
        Item.bgColor = Item.style.backgroundColor;
	    Item.fColor = Item.style.color;
	    Item.bColor = Item.style.borderTopColor;
        Item.style.backgroundColor = HoverItemBackColor;
		Item.style.color = HoverItemColor;
		Item.style.borderTopColor = Item.style.borderBottomColor = HoverBorderdColor;
		Item.style.fontWeight = 'bold';
    }
    
    //Item mouseout event handler.
    var OnMouseOut = function(CheckBox, Item)
    {
        if(CheckBox.checked) return;
				
		Item.style.backgroundColor = Item.bgColor;
	    Item.style.color = Item.fColor;
	    Item.style.borderTopColor = Item.style.borderBottomColor = Item.bColor;
		Item.style.fontWeight = 'normal';
    }
    
    //CheckBox click event handler.
	var OnClick = function(CheckBox, Item)
	{	
	    if(CheckBox.checked)
        {
			Item.style.backgroundColor = SelectedIItemBackColor;
			Item.style.color = SelectedItemColor;
			Item.style.borderTopColor = Item.style.borderBottomColor = SelectedIItemBackColor;
        }
        else
        {
            Item.style.backgroundColor = HoverItemBackColor;
		    Item.style.color = HoverItemColor;
			Item.style.borderTopColor = Item.style.borderBottomColor = HoverBorderdColor;
        }
	} 
	
    //Private anonymous method to wire up event handlers.
	var WireUpEventHandler = function(Target, Event, Listener)
	{
	    //Register event.
	    if(Target.addEventListener)	   
			Target.addEventListener(Event, Listener, false);	    
	    else if(Target.attachEvent)	   
			Target.attachEvent('on' + Event, Listener);
	    else 
	    {
			Event = 'on' + Event;
			Target.Event = Listener;	 
		}
		
	    //Collect event information through object literal.
	    var EVENT = { Target: Target, Event: Event, Listener: Listener }
	    EventHandlers.push(EVENT);
	}
	
	//Private anonymous  method to detach event handlers.
	var DetachEventHandler = function(EVENT)
	{
	    if(EVENT.Target.removeEventListener)	   
			EVENT.Target.removeEventListener(EVENT.Event, EVENT.Listener, false);	    
	    else if(EVENT.Target.detachEvent)	   
			EVENT.Target.detachEvent('on' + EVENT.Event, EVENT.Listener);
	    else 
		{
			EVENT.Event = 'on' + EVENT.Event;
			EVENT.Target.EVENT.Event = null;	 
	    }
	}
	 
	WireUpEventHandler(ListBoxDiv, 'contextmenu', function(){ return false; });
    Base.appendChild(ListBoxDiv);
}
    




