open Core.Std

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


  (* unregister should be notified by TCP connection cut off,
     so this is not a usual RPC server
     but anyway, first build a usual RPC server and then consider keeping connections after alive message.
  *)
