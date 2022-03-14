#[
minimal webbie

type: http://localhost:5151/hello

]#


import jester


settings:
  port = Port(5151)



routes:
  # type: http://localhost:5151/hello
  get "/hello":
    resp "Hello world"

