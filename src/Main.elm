module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Json.Decode as D
import Json.Decode.Pipeline as P
import Json.Encode as E
import MachineConnector


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Collection =
    { name : String
    , artistName : String
    , totalItems : Int
    , previewImgs : List String
    , chainIconImg : String
    }


type alias Model =
    { state : State
    , totalCollections : Int
    , collections : List Collection
    }


type State
    = Loading
    | Display
    | Failed


modelDecoder : D.Decoder Model
modelDecoder =
    D.map3 Model
        stateDecoder
        totalCollectionsDecoder
        collectionsDecoder


stateDecoder : D.Decoder State
stateDecoder =
    D.field "value" D.string
        |> D.andThen
            (\value ->
                case value of
                    "loading" ->
                        D.succeed Loading

                    "display" ->
                        D.succeed Display

                    "failed" ->
                        D.succeed Failed

                    v ->
                        D.fail ("Unknown state: " ++ v)
            )


totalCollectionsDecoder : D.Decoder Int
totalCollectionsDecoder =
    D.at [ "context", "totalCollections" ] D.int


collectionsDecoder : D.Decoder (List Collection)
collectionsDecoder =
    D.at [ "context", "collections" ] (D.list collectionDecoder)


collectionDecoder : D.Decoder Collection
collectionDecoder =
    D.succeed Collection
        |> P.required "name" D.string
        |> P.required "artistName" D.string
        |> P.required "totalItems" D.int
        |> P.required "previewImgs" (D.list D.string)
        |> P.required "chainIconImg" D.string


type Msg
    = StateChanged Model
    | DecodeStateError D.Error
    | ReloadClicked


init : () -> ( Model, Cmd Msg )
init _ =
    ( { state = Loading
      , totalCollections = 0
      , collections = []
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StateChanged m ->
            ( m, Cmd.none )

        DecodeStateError _ ->
            ( model, Cmd.none )

        ReloadClicked ->
            ( model
            , MachineConnector.event
                (E.object
                    [ ( "type", E.string "COLLECTIONS.RELOAD" )
                    ]
                )
            )


view : Model -> Html Msg
view model =
    div [ Attr.id "main__view" ]
        [ div []
            [ text <| "Total Collections: " ++ String.fromInt model.totalCollections
            ]
        , div [] <|
            case model.state of
                Display ->
                    List.map
                        (\collection ->
                            div [ Attr.style "margin-top" "20px" ]
                                [ div [] <|
                                    List.map
                                        (\pImg ->
                                            img [ Attr.style "margin-right" "20px", Attr.src pImg ]
                                                []
                                        )
                                        collection.previewImgs
                                , span [ Attr.style "margin-right" "20px" ] [ text collection.name ]
                                , span [ Attr.style "margin-right" "20px" ] [ text collection.artistName ]
                                , span [ Attr.style "margin-right" "20px" ] [ text <| String.fromInt (collection.totalItems - 3) ++ "+" ]
                                , img [ Attr.style "margin-right" "20px", Attr.src collection.chainIconImg ]
                                    []
                                ]
                        )
                    <|
                        model.collections

                Loading ->
                    [ span [] [ text "Loading..." ] ]

                Failed ->
                    [ span [] [ text "Failed!" ]
                    , button [ onClick ReloadClicked ] [ text "RETRY" ]
                    ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    MachineConnector.stateChanged
        (\value ->
            case D.decodeValue modelDecoder value of
                Ok m ->
                    StateChanged m

                Err e ->
                    DecodeStateError e
        )
