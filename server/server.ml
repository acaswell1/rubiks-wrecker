let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/:home"
      (fun request ->
        Dream.param "home" request
        |> Template.render
        |> Dream.html);

  ]
  @@ Dream.not_found