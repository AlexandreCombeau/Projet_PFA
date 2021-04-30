open Ecs
module Position = Component.Make(struct include Vector let name = "position" end)
module Velocity = Component.Make(struct include Vector let name = "velocity" end)
module Mass = Component.Make (struct type t = float let name = "mass" end)
module Box = Component.Make(struct include Rect let name = "box" end)
module Surface = Component.Make (struct include Texture let name = "texture" end)
module Name = Component.Make(struct type t = string let name = "name" end)
module CollisionResolver = Component.Make(struct type t = Entity.t -> Entity.t -> unit let name = "resolver" end)

module Resting = Component.Make(struct type t = bool let name = "nobounce" end)
module BounceRight = Component.Make(struct type t = bool let name = "bounceOfLeft" end)
module BounceLeft = Component.Make(struct type t = bool let name = "bounceOfRight" end)
module Dash = Component.Make(struct type t = bool let name = "canDash" end)
module Croushed = Component.Make(struct type t = bool let name = "isCroushed" end)
module Leaving = Component.Make(struct type t = bool let name = "leaving" end)
module Before = Component.Make(struct type t = bool let name = "inFrontOf" end)

module Background = Component.Make(struct type t = string let name = "imageID" end)

module SumForces = Component.Make (struct type t = Vector.t let name = "forces" end)

module Destination = Component.Make (struct include RoomInfo let name = "destination" end)