open Tyxml

let get_posts ?(dir=Sys.getcwd ()) () =
  print_endline dir;
  if Sys.is_directory dir then
    Sys.readdir dir
    |> Array.to_list
    |> List.filter
      (fun str ->
         let length = String.length str
         and ext = ".md" in
         String.sub str (length - String.length ext) length = ext)
  else assert false

let () =
  let posts = match Sys.argv with
    | [|dir|] -> get_posts ~dir ()
    | _ -> get_posts () in
  List.iter print_endline posts
