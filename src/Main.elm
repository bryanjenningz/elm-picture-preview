port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, src)
import Html.Events exposing (on)
import Json.Decode as Json exposing (Value)


type Msg
    = ProcessPicture Value
    | GetPicture String


type alias Model =
    { picture : String }


view : Model -> Html Msg
view model =
    div []
        [ img [ src model.picture ] []
        , input [ onChange ProcessPicture, type_ "file" ] []
        ]


onChange : (Value -> Msg) -> Attribute Msg
onChange message =
    on "change" (Json.map message Json.value)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProcessPicture value ->
            ( model, processPicture value )

        GetPicture picture ->
            ( { model | picture = picture }, Cmd.none )


port processPicture : Value -> Cmd msg


port getPicture : (String -> msg) -> Sub msg


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
