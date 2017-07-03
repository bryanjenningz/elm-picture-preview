-- We are using ports, so we have to put the "port" keyword
-- in front of our module declaration.


port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, src)
import Html.Events exposing (on)


-- Json.Decode as Json makes it so we don't have to type Json.Decode,
-- all we have to type is Json now. We're exposing the Value value,
-- which you can think of as being a JSON value. We'll be using
-- an "onchange" event object as a JSON value in this example.

import Json.Decode as Json exposing (Value)


-- We use the picture property in the model to store the URL
-- of the picture that the user uploads.


type alias Model =
    { picture : String }



-- We're going to need 2 message types. ProcessPicture Value
-- will be a message type that sends the image file onchange
-- event object to JavaScript to process. We aren't going to
-- process it at all in Elm, so we can just send it as a
-- Value type, which is what it is.
-- GetPicture String will be a message type that gets the resulting
-- picture URL and sets the picture property in the model to the
-- picture URL.


type Msg
    = ProcessPicture Value
    | GetPicture String



-- In our view, we just have a div element with an img element
-- and a file input element. The "onchange" event fires whenever
-- the user uploads an image. The ProcessPicture message will take
-- the event object as its Value type and then get passed into the
-- update function as the message argument.


view : Model -> Html Msg
view model =
    div []
        [ img [ src model.picture ] []
        , input [ onChange ProcessPicture, type_ "file" ] []
        ]



-- We are creating a custom event by using the Html.Events.on
-- function. We pass in "change" which means we listen for
-- "onchange" events. The (Json.map message Json.value) part is
-- a decoder. You can think of decoders as a tool for processing
-- JSON and turning it into an Elm value. If you don't need to
-- process the JSON in Elm, you can just leave it as it is by using
-- the Json.Decode.value decoder, which says "I just want to treat
-- this JSON as a blob that I won't touch right now".
-- Json.map takes 2 arguments, the first is the message
-- and the second argument is the decoder which specifies the type.
-- Since we are just going to send the JSON value to our
-- JavaScript, we can just use Json.Decode.value as the decoder.


onChange : (Value -> Msg) -> Attribute Msg
onChange message =
    on "change" (Json.map message Json.value)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- We are leaving the model the same and firing a command
        -- (processPicture value), which is a port that talks to
        -- JavaScript. When this command fires, the value will get
        -- sent to the JavaScript callback that's subscribed to the
        -- processPicture port.
        ProcessPicture value ->
            ( model, processPicture value )

        -- This is where the picture gets set. We have a subscription
        -- that listens to the getPicture port. So when the
        -- JavaScript code sends data to the getPicture port, it
        -- will get passed into the update function as the message
        -- GetPicture String type. We can just set the picture
        -- property to the picture string, which is the picture's
        -- URL.
        GetPicture picture ->
            ( { model | picture = picture }, Cmd.none )



-- Here's how we declare ports. The processPicture port is a
-- command port. Declaring it makes a function called processPicture
-- available to use in the update function. If you pass in a Value
-- type to it, that Value will get send to the JavaScript code
-- through the processPicture port. We will use this port to send
-- our event object to the JavaScript to process the picture.


port processPicture : Value -> Cmd msg



-- This is how we declare a subscription port.
-- A subscription port is a port that listens to JavaScript.
-- Since the JavaScript code sends a String back which is the
-- picture URL, we need to pass in a type that takes in a
-- String and returns a msg. The msg will be passed into our
-- update function. We will be using GetPicture String to do this.


port getPicture : (String -> msg) -> Sub msg



-- To set up our getPicture port so that we are subscribed to it,
-- we make it the subscription that the subscriptions function
-- returns. The getPicture port will listen for when the JavaScript
-- code sends the picture URL. We then will pass that string into
-- the GetPicture String message type which will get passed to the
-- update function.


subscriptions : Model -> Sub Msg
subscriptions model =
    getPicture GetPicture


main : Program Never Model Msg
main =
    program
        { init = ( Model "", Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
