open Core.Std
open Async.Std

module NodeType = struct
  type t = NormalNode | HiddenNode (* ever used? *) with bin_io
end

module Protocol = struct
  type t = TcpIpV4 with bin_io
end

module Registration = struct
    type t = {
      port_no : int;
      node_type : NodeType.t;
      protocol : Protocol.t;
      highest_version : int option;
      lowest_version : int option;
      node_name : string;
      extra : string;
    } with bin_io
end

module Message = struct

  module AliveResp = struct
    type t = [`OK | `Error] with bin_io
  end

  module PortPlease = struct
    type t = {
      node_name : string;
    } with bin_io
  end
  module PortResp = struct
    type t =
      | Failure
      | Success of Registration.t with bin_io
  end
  (* NamesReq *)
  module NamesResp = struct
    module NodeInfo = struct
      type t = {
        node_name : string;
        port : int;
      } with bin_io
    end
    type t = NodeInfo.t list with bin_io
  end
  (* DumpReq *)
  module DumpResp = struct
    module NodeInfo = struct
      type t = {
        status : [`Active | `Old];
        port : int;
        fd : int;
      } with bin_io
    end
    type t = NodeInfo.t list with bin_io
  end

    (* suddenly noticed that client messages and server messages should be separated *)
  type request = AliveReq of Registration.t | PortPlease of PortPlease.t | NamesReq | DumpReq | KillReq with bin_io
  type response = AliveResp of AliveResp.t | PortResp of PortResp.t | NamesResp of NamesResp.t | DumpResp of DumpResp.t | KillResp with bin_io
end


module DispatchError = struct
  type t = [`NameUsed | `Sadly of string ] with bin_io
end

let rpc = Rpc.Pipe_rpc.create
  ~name:"ppmd"
  ~version:2
  ~bin_query:Message.bin_request
  ~bin_response:Message.bin_response
  ~bin_error:DispatchError.bin_t
;;

(* I need a function of this type
('connection_state
        -> 'query
        -> aborted:unit Deferred.t
        -> ('response Pipe.Reader.t, 'error) Result.t Deferred.t)
*)
(* what is the Result.t here? / just like Either *)
(* is the error response returned back to the client?
   Aha, when the call is wrong.
*)



