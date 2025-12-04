type name = Name of string
(** Le nom ne contient pas de '/' *)

type path = name list

type file = { 
  name: name; 
  content: string ;
  created_at: float;    
  id: int;
  }

type directory = { 
  name: name; 
  children: node list;
  created_at: float;    
  id: int;
 }
and node = File of file | Dir of directory

type filesystem = { 
  root: directory; 
  current_path: path; 
  next_id: int 
  }



(* Les déclarations des deux types suivants sont mutuellement récursifs:
  - le type directory des répertoires est un enregistrement dont le champ children contient une liste de node
  - le type node est un type de données algébrique dont un des constructeurs encapsule une valeur de type directory
*)


let init () =
  let root_dir = { 
    name = Name "/"; 
    children = [] ;
    created_at = Unix.time ();    
    id = 0
    } in
  (* Le répertoire racine est le seul nom de répertoire qui peut contenir un '/' *)
  { root = root_dir; 
  current_path = [] ;
  next_id = 1 ;
  }


let path_to_string path =
  let names = List.map (fun (Name s) -> s) path in
  String.concat "/" names

