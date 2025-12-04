let split_ws (s : string) : string list =
  let str_l = String.split_on_char ' ' s in
  List.filter (fun t -> t <> "") str_l

let rec loop (fs : Filesystem.filesystem) : unit =
  (* Affiche le chemin courant en couleur  *)
  Printf.printf "\027[32m%s\027[0m> %!" (Filesystem.path_to_string fs.current_path);
  match read_line () with
  | exception End_of_file -> print_newline ()
  | line ->
      let tokens = split_ws line in
      begin
        match tokens with
        | "quit" :: _ | "exit" :: _ ->
            print_endline "Exit"
        | [] -> loop fs

        (* Insérer les commandes ici *)
        | "mkdir" :: dirname :: _ ->
            loop (Commands.mkdir fs dirname)

        | "touch" :: filename :: _ ->
            loop (Commands.touch fs filename)
(*
        | "ls-l" :: _ ->
          Commands.ls_l fs;
            loop fs
*)
        | "ls" :: _ ->
            let _ = Commands.ls fs in   (* on exécute la commande *)
            loop fs                     (* on continue avec le même fs *)

        | "cat" :: filename :: _ ->
            let _ = Commands.cat fs filename in
            loop fs

        | "pwd" :: _ ->
            let _ = Commands.pwd fs in
            loop fs


        | "cd" :: dirname :: _ ->
            loop (Commands.cd fs dirname)

        | "rm" :: name_elem :: _ ->
            loop (Commands.rm fs name_elem)

        | "mv" :: name_elem :: new_dir :: _ ->
            loop (Commands.mv fs name_elem new_dir)

        | "cp" :: name_elem :: new_dir :: _ ->
            loop (Commands.cp fs name_elem new_dir)

          
        | command :: _ ->
            Printf.eprintf "Command not found: %s\n%!" command;
            loop fs
      end


