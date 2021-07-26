%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(controller_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

-define(GitHostConfigCmd,"git clone https://github.com/joq62/host_config.git").
-define(HostFile,"host_config/hosts.config").
-define(HostConfigDir,"host_config").


%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_0(),
    io:format("~p~n",[{"Stop pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_1(),
    io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=pass_2(),
%    io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=pass_3(),
%    io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_4(),
  %  io:format("~p~n",[{"Stop pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_5(),
  %  io:format("~p~n",[{"Stop pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
 
    
   
      %% End application tests
    io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
    io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_0()->
    [{"c0",_,22,"joq62","festum01"},
     {"c0",_,22,"joq62","festum01"}]=etcd:host_info_read("c0"),
    {atomic,[ok]}=etcd:host_info_delete("c0","192.168.0.200",22,"joq62","festum01"),
    [{"c0","192.168.1.200",22,"joq62","festum01"}]=etcd:host_info_read("c0"),
    "test_cluster"=etcd:cluster_name(),
    "abc"=etcd:cluster_cookie(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
    [{"c1","192.168.0.201",22,"joq62","festum01"},
     {"c0","192.168.0.200",22,"joq62","festum01"},
     {"joq62-X550CA","192.168.0.100",22,"joq62","festum01"}]=host_controller:running_hosts(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_5()->

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_3()->
  
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_4()->
  
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->
    ok=cluster_lib:load_config(?HostConfigDir,?HostFile,?GitHostConfigCmd),
    {ok,HostInfoConfig}=cluster_lib:read_config(?HostFile),
    [etcd:host_info_create(HostId,Ip,SshPort,UId,Pwd)||
	    [{host_id,HostId},
	     {ip,Ip},
	     {ssh_port,SshPort},
	     {uid,UId},
	     {pwd,Pwd}]<-HostInfoConfig],

    [{"c0",_,22,"joq62","festum01"},
     {"c0",_,22,"joq62","festum01"}]=etcd:host_info_read("c0"),
    {atomic,[ok]}=etcd:host_info_delete("c0","192.168.0.200",22,"joq62","festum01"),
    [{"c0","192.168.1.200",22,"joq62","festum01"}]=etcd:host_info_read("c0"),
    
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
-define(APP,controller). 
setup()->
    rpc:call(node(),application,stop,[?APP],10*5000),
    timer:sleep(500),
    application:set_env([{?APP,[{is_leader,true},
				{cluster_name,"test_cluster"},
				{cookie,"abc"},
				{num_controllers,3},
				{hosts,["c0","c1"]}]}]),
    ok=rpc:call(node(),application,start,[?APP],10*5000),
    {pong,_,?APP}=rpc:call(node(),?APP,ping,[],1*5000),	
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    application:stop(controller),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
