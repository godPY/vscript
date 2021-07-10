//원제작자 : https://www.youtube.com/channel/UCTvJLhaTrUSK06c1KLFRpxA
//
//목적 : 같은 틱에서 다수의 이벤트가 실행될시 이벤트 데이터가 덮어씌워지는 오류 수정
//
//어떻게 사용하는가?
//1. logic_script 엔티티의 스크립트에 event.nut 을 넣고 EntityGroup에 등록할 logic_eventlistener 엔티티들의 이름을 각각 넣어둔다.
//2. Event_Data에 EntityGroup에 등록한 logic_eventlistener 타겟네임을 넣어둔다.
//3. logic_eventlistener의 아웃풋에 인수로 있던 event_data를 빈칸으로 바꾼다. ex. OnEventFired:listen_disconnect:RunScriptCode:PlayerDisconnect(event_data):0.00:0
//								-> OnEventFired:listen_disconnect:RunScriptCode:PlayerDisconnect():0.00:0
//4. logic_eventlistener에서 사용되던 함수를 변형시킨다.
//예시1
/*
::PlayerDisconnect <- function(event){ // Remove UserID index from Players when player disconnects
	DebugPrint("[DEBUG] " +Players[event.userid] + " : " + event.userid);
}

->

::PlayerDisconnect <- function(){ 
		local event = getData("listen_disconnect");
		DebugPrint("[DEBUG] " +Players[event.userid] + " : " + event.userid);
	}
*/
//
//	현제 발생하는 문제.
//	'4ca1ea159_player_say' does not exist 같은 식의 오류가 매 라운드 발생한다.
//	다만 이것이 실제로 문제를 일으키진 않으므로 신경쓸 필요는 없다.
//



::Event_Data <- {
    //targetnames of the eventListener entities
	listen_info = [],
	listen_join = [],
	listen_say = [],
	listen_disconnect = []
};
::getData <- function(slotName){
    local event_data = Event_Data[slotName][0];
    Event_Data[slotName].remove(0);
    return event_data;
}


function OnPostSpawn(){
    //for each event listener
    foreach(handle in EntityGroup){
        handle.ValidateScriptScope();
        local scope = handle.GetScriptScope();
        local n = handle.GetName(); //should match slotnames from the table above
        //delete existing event_data table
        if("event_data" in scope){delete scope.event_data;}
        scope.eventdata <- Event_Data[n].weakref();
        delegate {function _newslot(k, v){eventdata.push(v)}}:scope;//make sure to do this last!!
    }
    printl("event.nut Loaded");
}

//function OnPlayerDisconnect(){
//	local data = getData("listen_disconnect");
//	PlayerDisconnect(data);
//}
