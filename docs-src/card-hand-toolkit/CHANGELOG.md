# Changelog

## 1.0.0

First release.

- **Hands:** a Player Hand that fans cards out along an editable curve (Fan Layout Profile), focuses and lowers on click or tap, and lets players reorder cards by dragging. Opponent hands show face-down cards for each extra seat.
- **Hover:** hovered cards in the hand lift, scale and come forward; out of the hand, a large preview opens in an overlay. Mouse and touch each have their own timings (Hover Profile).
- **Drag and play:** dragging a card above the hand's Play Height plays it into the first zone that accepts it. Includes a row zone (`LineBoardZone`) and a single-slot zone (`SingleSlotZone`), and an `IPlayResolver` interface for your own.
- **Interaction rules:** a global policy, per-zone policies and per-card overrides decide whether each card can be hovered, dragged, selected or targeted.
- **Card data:** `ScriptableCard` assets with a name, rules text, art, frame and tags; a Card Database; and addons for your own data, such as cost or suit.
- **Card visuals:** a 3D card with its frame, art and back from a Frame Library, and a UI World View for text and fields. View models, binders and field toggles let you show your own data without changing the toolkit. SingleSprite mode supports cards made as one finished image.
- **Decks:** Deck Lists, runtime decks with draw, shuffle, discard and empty-deck policies, and optional visual draw and discard piles. Piles spread up to eight visible layers by default (configurable), retaining the remaining cards at separate depths behind the bottom visible layer.
- **Setup Wizard:** creates your own copies of the toolkit's assets and sets up a playable Game scene. The Game Camera option includes a replaceable blue background, with its Canvas assigned to the new camera.
- **Input and platforms:** works with the Legacy Input Manager and the Input System, on desktop, iOS and Android, in the Built-in Render Pipeline and URP.
- **Sample:** a complete single-player card game vs a computer opponent (`Sample_GameScene`) with cost and suit addons.
- **Documentation:** Quick Start, API reference and FAQ.
