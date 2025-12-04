open Filesystem
(*-------------------fonctions auxiliare------------------------*)
(* Vérifie si un élément portant target_name existe dans children *)
let rec existe children target_name =
  match children with
  | [] -> false
  | File f :: rest ->
      if f.name = target_name then true
      else existe rest target_name
  | Dir d :: rest ->
      if d.name = target_name then true
      else existe rest target_name

(* Transforme un type name en type string *)
let nameToString = fun (Filesystem.Name s) -> s

(* Vérifie si un nom contient un '/' *)
let check_name s = String.contains s '/'

(*fonctions auxiliare qui cherche un fichier ou repertoire
parmi les children par son nom (target)*)
let rec find_dir children target = match children with
   | [] -> None
   |Dir d::rest ->
    if d.name = target then Some (Dir d)
    else find_dir rest target
   |_ :: rest -> find_dir rest target

(**)
let rec find_node children target = match children with
   | [] -> None
   |File f::rest ->
      if f.name = target then Some (File f)
      else find_node rest target
    | Dir d :: rest ->
      if d.name = target then Some (Dir d)
      else find_node rest target


(*fonction auxiliare qui cherche le repertoire courant a partir
 de la racine et du chemin courant*)
let rec get_dir root path = match path with
    |[] -> root
    |Name n :: rest ->
      match find_dir root.children (Name n) with
      |None -> failwith "Chemin invalide"
      |Some(File _) -> failwith "Chemin invalide : un fichier est rencontré au lieu d'un répertoire"
      |Some (Dir d) -> get_dir d rest

(*fonction auxiliare qui met a jour le contenu d'un fichier
dans une liste de children*)
let rec update_file children filename text = match children with
  | [] -> []
  | File f :: rest ->
      if f.name = filename then
        let new_content = f.content ^ "\n" ^text in
        (*let new_size = String.length new_content in*)
        File { f with content = new_content; 
        (*size = new_size*)
        } :: rest
      else
        File f :: update_file rest filename text
  | Dir d :: rest ->
      Dir d :: update_file rest filename text

(*fonction auxiliare qui met a jour un repertoire dans l'arborescence
 en appliquant une fonction u sur la liste des enfants du repertoire, la
  fonction u permet d'ajouter un nouveau dossier ou fichier dans children*)
let rec update_dir dir path u =
        match path with
        | [] -> {dir with children = u dir.children}  (*ajoute le nouveau dossier dans children*)
        | Name p :: rest ->
          let rec aux l = match l with
            |[] -> []
            | Dir d :: tl ->
              if d.name = Name p then
                Dir (update_dir d rest u) :: tl
              else
                Dir d :: aux tl
            | File f :: tl -> File f :: aux tl
          in
          {dir with children = aux dir.children}

(*normalise le chemin en supprimant les . et les ..*)
let rec normalize_path path = match path with
  | [] -> []
  | Name "." :: rest -> normalize_path rest
  | Name ".." :: rest ->
      (match normalize_path rest with
      | [] -> [] (*deja a la racine*)
      | _ :: tail -> tail) (*supprimer le dernier element*)
  | n :: rest -> n :: normalize_path rest

(*-----------------------les commandes-----------------------------------*)

(**
let next_id = ref 0

let fresh_id () =
  let id = !next_id in
  next_id := id + 1;
  id
*)

(* met à jour un répertoire dans l'arborescence à un chemin donné *)



(* mkdir : créer un répertoire dans le répertoire courant *)
let mkdir fs dirname =
  if check_name dirname then
    (print_endline "mkdir: le nom ne doit pas contenir de '/'"; fs)
  else
  let new_name = Name dirname in
  let current_dir = get_dir fs.root fs.current_path in (*recupere le dossier courant*)
    if existe current_dir.children new_name then
      (print_endline "mkdir: un repertoire avec ce nom existe deja" ; fs)
    else
      let new_dir =Dir { name = new_name; children = [] } in
      let new_root = update_dir fs.root fs.current_path
      (fun children -> new_dir :: children)
      in
      { fs with root = new_root }


(* touch : créer un fichier vide dans le répertoire courant *)
let touch fs filename =
  let new_name = Name filename in
  let current_dir = get_dir fs.root fs.current_path in
  (* Vérifier si le fichier existe déjà *)
  if existe current_dir.children new_name then
    (print_endline "touch: un élément avec ce nom existe déjà" ; fs)
  else
    (* Nouveau fichier vide *)
    let new_file = File { name = new_name; content = "" ; 
    (*size = 0*)
    } in
    (* Met à jour les enfants du répertoire courant *)
    let new_root =  update_dir fs.root fs.current_path
      (fun children -> new_file :: children) in
    { fs with root = new_root }


(* ls_l *)
(*let ls_l fs =
  let rec print children =
    match children with
    | [] -> ()
    | File f :: rest ->
        let Name n = f.name in
        print_endline (n ^ "   id=" ^ string_of_int f.id ^
                       "   created=" ^ string_of_float f.created_at);
        print rest
    | Dir d :: rest ->
        let Name n = d.name in
        print_endline (n ^ "/   id=" ^ string_of_int d.id ^
                       "   created=" ^ string_of_float d.created_at);
        print rest
  in
  print fs.root.children
*)


(* rm : supprimer un fichier ou un répertoire dans la racine *)
let rm fs name =
  let current = get_dir fs.root fs.current_path in
  let target = Name name in

  let new_children =
    List.filter (function
      | File f -> f.name <> target
      | Dir d  -> d.name <> target
    ) current.children
  in

  if new_children = current.children then (
    print_endline ("rm : " ^ name ^ " introuvable"); fs
  ) else
    let updated = { current with children = new_children } in
      { fs with root = update_dir fs.root fs.current_path (fun _ -> updated.children) }


(* mv : déplacer un élément  *)
let mv fs name dest =
  let current = get_dir fs.root fs.current_path in
  let target = Name name in

  match find_node current.children target with
  | None -> print_endline "mv : élément introuvable"; fs
  | Some node ->
      (* Supprime l'élément du répertoire courant *)
      let fs = rm fs name in

      (* Construit le chemin de destination *)
      let parts = List.filter ((<>) "") (String.split_on_char '/' dest) in
      let dest_path = fs.current_path @ List.map (fun x -> Name x) parts in

      (* Vérifie que le répertoire de destination existe *)
      let rec check dir path =
        match path with
        | [] -> Some dir
        | Name n :: r ->
            match find_dir dir.children (Name n) with
            | Some (Dir d) -> check d r
            | _ -> None
      in

      match check fs.root dest_path with
      | None -> print_endline "mv : destination introuvable"; fs
      | Some dest_dir ->
          (* Ajoute l'élément dans le répertoire de destination *)
          let updated_dest = { dest_dir with children = node :: dest_dir.children } in
          { fs with root = update_dir fs.root dest_path (fun _ -> updated_dest.children) }


(* cp : copier un élément *)
let rec clone_node = function
  | File f -> File { f with content = f.content }
  | Dir d  -> Dir { d with children = List.map clone_node d.children }

let cp fs name dest =
  let current = get_dir fs.root fs.current_path in
  let target = Name name in

  match find_node current.children target with
  | None -> print_endline "cp : élément introuvable"; fs
  | Some node ->
      let copy = clone_node node in
      let parts = List.filter ((<>) "") (String.split_on_char '/' dest) in
      let dest_path = fs.current_path @ List.map (fun x->Name x) parts in

      let rec check dir path =
        match path with
        | [] -> Some dir
        | Name n :: r ->
            match find_dir dir.children (Name n) with
            | Some(Dir d) -> check d r
            | _ -> None
      in

      match check fs.root dest_path with
      | None -> print_endline "cp : destination introuvable"; fs
      | Some dest_dir ->
          let updated = { dest_dir with children = copy :: dest_dir.children } in
      { fs with root = update_dir fs.root dest_path (fun _ -> updated.children) }


(* Commande ls : affiche la liste des repertoires et les fichier
dans le repertoire courant. Parcourt fs.root.children et affiche chaque nom *)
let ls (fs : Filesystem.filesystem) =
  let current_dir = get_dir fs.root fs.current_path in
  let rec aux l =
    match l with
    | [] -> fs
    | Filesystem.File f :: l' ->
        let Name fname = f.name in
        (*Printf.printf "%s(taille: %d octets)\n" fname f.size;*)

        print_endline fname;
        aux l'
    | Filesystem.Dir d :: l' ->
        print_endline (nameToString d.name);
        aux l'
    in
  aux current_dir.children


(*qui permet d’afficher le chemin absolu vers le répertoire courant*)
let pwd (fs : Filesystem.filesystem) =
  if fs.current_path = [] then
    (Printf.printf "/\n" ;
    fs )
  else (
    let path = Filesystem.path_to_string fs.current_path in
    Printf.printf "%s\n" path;
  fs  )



(* qui permet de se déplacer dans l’arborescence en suivant le chemin
 relatif nomchemin pour modifier le chemin courant. Elle affiche une erreur si ce chemin
 relatif ne mène à aucun répertoire existant.*)
let cd (fs : Filesystem.filesystem) path =
  (*decoupe le chemin en plusieurs morceaux*)
  let split_path = String.split_on_char '/' path in
  (*enleve les morceaux vides de path*)
  let rec remove_empty str_list = match str_list with
    | [] -> []
    | "" :: t -> remove_empty t
    | x::tl  -> Name x :: remove_empty tl
  in
  let parts = remove_empty split_path in
  let new_path =
    (*cas pour la racine*)
    if String.length path > 0 && path.[0] = '/' then
      parts
    else
      fs.current_path @ parts
    in
  let normalize_path = normalize_path new_path in
  (*vérifie si le chemin est valide et present*)
  let rec check_path dir path = match path with
    | [] -> Some dir
    | Name n::rest ->
      match find_dir dir.children (Name n) with
      | None -> None
      | Some (File _) -> failwith("cd: chemin invalide : un fichier est rencontré au lieu d'un répertoire")
      | Some (Dir d) -> check_path d rest
    in
  match check_path fs.root normalize_path with
      |None -> Printf.printf "cd ; chemin %s introuvable" path;
       fs
      |Some _ -> { fs with current_path = normalize_path }


(* Écrit du texte dans un fichier existant.
   - Cherche le fichier par son nom
   - Si introuvable, affiche une erreur.
   - Si c’est un répertoire, affiche une erreur.
   - Si c’est bien un fichier, remplace son contenu par le texte fourni. *)
(*let write fs  filename text =
    let n = Name filename in
    (*mettre a jour le repertoir sur lequel on se trouve*)
    let current_dir = get_dir fs.root fs.current_path in
   match find_node current_dir.children n with
    | None ->
        Printf.printf "Erreur : fichier %s introuvable\n" filename;
        fs
    | Some (Dir _) ->
        Printf.printf "Erreur : %s est un répertoire\n" filename;
        fs
    | Some (File f) ->
          let new_content = f.content ^ "\n" ^ text in
          let new_size = String.length new_content in
          let delta = new_size - f.size in
          let new_used = fs.used + delta in
          (* Vérifie la limite mémoire *)
          match fs.limit with
          | Some limit when new_used > limit ->
              Printf.printf "Erreur : espace insuffisant (limite %d atteinte)\n" limit;
              fs
          | _ ->
            (*fonctions auxiliare pour reconstruire le repertoire
              elle applique une modification locale (avec update_file) dans un fichier,
              puis recrée tout le chemin jusqu’à la racine*)
              let rec update_dir dir path =
                match path with
                | [] -> {dir with children = update_file dir.children n text}
                | Name p :: rest ->

                  let rec aux l = match l with
                    |[] -> []
                    | Dir d :: tl ->
                      if d.name = Name p then
                        Dir (update_dir d rest) :: tl
                      else
                        Dir d :: aux tl
                    | File f :: tl -> File f :: aux tl
                  in
                  {dir with children = aux dir.children}
        in
        let newroot =  update_dir fs.root fs.current_path in
        { fs with root = newroot }
*)

(* Affiche le contenu d’un fichier.
   - Cherche le fichier par son nom Si introuvable, affiche une erreur.
   - Si c’est un répertoire, affiche une erreur.
   - Si c’est bien un fichier, affiche son contenu avec print_endline. *)

let cat fs filename =
    let n = Name filename in
    match find_node fs.root.children n with
    | None ->
        Printf.printf "Erreur : fichier %s introuvable\n" filename;
        fs
    | Some (Dir _) ->
        Printf.printf "Erreur : %s est un répertoire\n" filename;
        fs
    | Some (File f) ->
        print_endline f.content;
        fs

(*affiche tous les fichiers s’appelant nomdufichier dans
 la sous-arborescence partant du répertoire courant. Le chemin absolu de chacun de ces
 fichiers est affiché.*)
let find fs filename =
  let Name n = Name filename in
  let rec aux dir current_path =
    List.iter (fun child ->
      match child with
      | File f ->
          let Name fname = f.name in
          if fname = n then
            let full_path = Filesystem.path_to_string (current_path @ [f.name]) in
            Printf.printf "%s\n" full_path
      | Dir d ->
          aux d (current_path @ [d.name])
    ) dir.children
  in
  let current_dir = get_dir fs.root fs.current_path in
  aux current_dir fs.current_path;
  fs

(*let set_limit fs max_size =
  { fs with limit = Some max_size }*)