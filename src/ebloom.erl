%% -------------------------------------------------------------------
%%
%% Copyright (c) 2010 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(ebloom).
-author('Dave Smith <dizzyd@dizzyd.com>').
-export([new/3,
         insert/2,
         contains/2,
         clear/1,
         size/1,
         elements/1,
         effective_fpp/1,
         intersect/2,
         union/2,
         difference/2,
         serialize/1,
         deserialize/1]).

-ifdef(TEST).
-ifdef(EQC).
-include_lib("eqc/include/eqc.hrl").
-define(QC_OUT(P),
        eqc:on_output(fun(Str, Args) -> io:format(user, Str, Args) end, P)).
-endif.
-include_lib("eunit/include/eunit.hrl").
-endif.

-on_load(init/0).

-define(nif_stub, nif_stub_error(?LINE)).
nif_stub_error(Line) ->
    erlang:nif_error({nif_not_loaded,module,?MODULE,line,Line}).

-spec init() -> ok | {error, any()}.
init() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, bad_name} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Path ->
                      Path
              end,
    erlang:load_nif(filename:join(PrivDir, atom_to_list(?MODULE)), 0).

-spec new(integer(), float(), integer()) -> {ok, reference()}.
new(_Count, _FalseProb, _Seed) ->
    nif_stub.

-spec insert(reference(), binary()) -> ok.
insert(_Ref, _Bin) ->
    nif_stub.

-spec contains(reference(), binary()) -> true | false.
contains(_Ref, _Bin) ->
    nif_stub.

-spec clear(reference()) -> ok.
clear(_Ref) ->
    nif_stub.

-spec size(reference()) -> integer().
size(_Ref) ->
    nif_stub.

-spec elements(reference()) -> integer().
elements(_Ref) ->
    nif_stub.

-spec effective_fpp(reference()) -> float().
effective_fpp(_Ref) ->
    nif_stub.

-spec intersect(reference(), reference()) -> ok.
intersect(_Ref, _OtherRef) ->
    nif_stub.

-spec union(reference(), reference()) -> ok.
union(_Ref, _OtherRef) ->
    nif_stub.

-spec difference(reference(), reference()) -> ok.
difference(_Ref, _OtherRef) ->
    nif_stub.

-spec serialize(reference()) -> binary().
serialize(_Ref) ->
    nif_stub.

-spec deserialize(binary()) -> {ok, reference()}.
deserialize(_Bin) ->
    nif_stub.

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

basic_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    0 = elements(Ref),
    insert(Ref, <<"abcdef">>),
    true = contains(Ref, <<"abcdef">>),
    false = contains(Ref, <<"zzzzzz">>).

union_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    insert(Ref, <<"abcdef">>),
    false = contains(Ref2, <<"abcdef">>),
    union(Ref2, Ref),
    true = contains(Ref2, <<"abcdef">>).

serialize_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    Bin = serialize(Ref),
    Bin2 = serialize(Ref2),
    true = (Bin =:= Bin2),
    insert(Ref, <<"abcdef">>),
    Bin3 = serialize(Ref),
    {ok, Ref3} = deserialize(Bin3),
    true = contains(Ref3, <<"abcdef">>),
    false = contains(Ref3, <<"rstuvw">>).

clear_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    0 = elements(Ref),
    insert(Ref, <<"1">>),
    insert(Ref, <<"2">>),
    insert(Ref, <<"3">>),
    3 = elements(Ref),
    clear(Ref),
    0 = elements(Ref),
    false = contains(Ref, <<"1">>).

-endif.
