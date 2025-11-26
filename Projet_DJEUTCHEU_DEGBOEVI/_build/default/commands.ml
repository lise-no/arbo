open filesystem

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

