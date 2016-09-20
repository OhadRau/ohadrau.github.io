open Omd
open Tyxml
open Core.Std
open Filename

let get_posts src =
  if Sys.is_directory src = `Yes then
    Sys.readdir src
    |> Array.to_list
    |> List.filter ~f:(fun f -> check_suffix f ".md")
  else assert false

let html_of_file file =
  file |> In_channel.read_all |> Omd.of_string |> Omd.to_html |> Html.pcdata

let make_link (post_url, post_title) =
  Html.(a ~a:[a_href post_url] [pcdata post_title])

let make_index post_info = [%html {|
  <html>
    <head>
      <meta charset="UTF-8"/>
      <title>ohad.space blog</title>
    </head>
    <body>
      <div id="posts">|} (List.map ~f:make_link post_info) {|</div>
    </body>
  </html>
|}]

let create_blog ?(src=Sys.getcwd ()) ~dest () =
  let posts = get_posts src in
  let post_info =
    List.map
      ~f:(fun name ->
          (concat dest name, chop_extension name)) posts in
  let file_handle = open_out (concat dest "index.html") in
  let fmt = Format.formatter_of_out_channel file_handle in
  make_index post_info |> Html.pp () fmt;
  Out_channel.close file_handle

let () =
  match Sys.argv with
    | [|_; "-from"; src; "-to"; dest|]
    | [|_; "-to"; dest; "-from"; src|] -> create_blog ~src ~dest ()
    | [|_; "-to"; dest|] -> create_blog ~dest ()
    | _ -> print_endline ("Usage: " ^ Sys.argv.(0) ^ " -from <dir> -to <dir>")
