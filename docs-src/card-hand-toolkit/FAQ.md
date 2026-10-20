# Card Hand Toolkit — FAQ

New to the toolkit? Start with the [Quick Start](QuickStart.md). For every class and interface, see the [API Reference](API.md).

## Getting started

**Q: Which sections should I read first?**
A: After the [Quick Start](QuickStart.md), read the [Concepts](API.md#concepts) in the API Reference, then the module guide for what you're building: [Zones & Play](API.md#zones--play) for where cards go, [Card Data & Decks](API.md#card-data--decks) for drawing and dealing, [Card Visuals](API.md#card-visuals) for how cards look, [Interaction](API.md#interaction) for hover, drag and tap, and [Hands & Layout](API.md#hands--layout) for the hands themselves.

**Q: What’s safe to modify?**
A: Anything tagged **[C]** in the API Reference is intended for configuration. Types tagged **[E]** are designed for extension via interfaces/policies. Types tagged **[L]** are primarily informational.

Don't edit files inside `Assets/CardHandToolkit/` (other than `Config/`, which the Setup Wizard creates for you). A toolkit update can replace them. Instead:

- **Change a prefab in your scene,** such as the Player Hand or a zone, by editing the instance in the scene. Those changes are saved in your scene, not in the toolkit's prefab.
- **Use your own settings asset,** such as a Fan Layout Profile, by creating one from **Create ▸ Card Toolkit** and assigning it in place of the shipped `CHT_` one.
- **Change the prefab itself** by making a Prefab Variant (right-click the prefab ▸ **Create ▸ Prefab Variant**) and using that instead.

**Q: Do I have to use `LineBoardZone` and `SingleSlotZone`?**
A: No. They're examples of play zones. Use them as they are, or write your own by implementing `ICardZone` and `IPlayResolver`. The hands, deck and discard visuals are meant to be used as they are.

## Interaction and decks

**Q: How do I change what a card allows: hover, drag, select or target?**
A: Supply an `IInteractionPolicy` globally through **Override Policy Asset** on `CardToolkitRuntime`, or per zone through `IInteractionPolicyProvider`. Add `CardInteractionOverride` for individual cards. After changing game state that your policy reads, call `InteractionController.RefreshAll()` (or `Refresh()` for one card). See [Permissions and policies](API.md#permissions-and-policies).

**Q: Can I block dragging on one specific card?**
A: Add **Card Interaction Override** to that card and tick **Drag** in **Deny**. Deny wins over Allow. If you change the masks at runtime, call `Refresh()` on that card's `InteractionController`. See [IInteractionOverride / CardInteractionOverride](API.md#iinteractionoverride--cardinteractionoverride-ce).

**Q: What happens when the deck is empty?**
A: `Draw()` asks the deck's `IEmptyDeckPolicy` to refill it. The default `ReshuffleOnEmpty` shuffles the discard pile back in; `NoReshufflePolicy` leaves it empty. If the policy can't refill it, `EmptyEvent` fires and `Draw()` returns only the cards it could draw, possibly none. See [Decks](API.md#decks).

**Q: Can players reorder cards in their hand by dragging?**
A: Yes. Release inside the Player Hand's reorder band to move a card to that position. For a custom hand, implement `IReorderBandZone`; `DragCard` uses it to compute the insert index. See [The Player Hand](API.md#the-player-hand).

**Q: How does hover differ between mouse and touch?**
A: In a focused hand, mouse-over or holding a finger on a card lifts it. Out of the hand, the mouse opens a preview after a short delay; touch opens it after a long press, and tapping the backdrop closes it. Tune timings and placement on the **Hover Profile**, assigned on `CardToolkitRuntime`. See [Hover](API.md#hover).

## Troubleshooting

**Q: Why does mouse hover flicker near the bottom of the screen?**
A: Check the Player Hand's **Hover Anchor**: its cyan gizmo line should be at or below the bottom edge of the screen, so a lifted card doesn't expose the next card under the pointer. Check its **Reference Card** if you've changed the card prefab's collider or scale. See [HoverAnchor](API.md#hoveranchor-c).

**Q: I pressed Play and got "No CardToolkitRuntime found in scene".**
A: The scene you pressed Play from has no `CHT_CardToolkitLoader`. The Setup Wizard puts one in your Game scene. For any other scene with cards, copy the loader from your Game scene into it.

**Q: The Console says "CardToolkitRuntime missing CardDatabase reference" (or CardFrameLibrary, HoverProfile, ICardVisualFactory).**
A: A field on the `CHT_CardToolkitLoader` in your scene is empty. Select the loader and assign the missing asset on its `CardToolkitRuntime` component, or run the Setup Wizard again on that scene with **Use Existing**. If the error is about `HoverPolicyRuntime` instead, that component is missing from the loader. Replace the loader with a fresh `CHT_CardToolkitLoader` prefab and run the Wizard on the scene.

**Q: My cards' frame or back is plain white.**
A: Cards take their frame and back from the **CardFrameLibrary** at runtime, not from the card materials. Set its **Default Frame** and **Default Card Back**. The textures on `CardFrontMat_User` and `CardBackMat_User` only show in the editor.

**Q: A card shows the wrong frame.**
A: Check the card's **Frame Key**. An empty key, or a key that doesn't match any entry in the CardFrameLibrary's **Frames** list, uses the **Default Frame**.

**Q: My custom field never shows.**
A: Check that the same key is used in three places: the FieldToggle's **Custom Key**, the Card Skin's **Enabled Custom Fields**, and the key your ViewModel passes to `SetCapability`. Keys aren't case-sensitive. A key that's missing from the Card Skin logs a one-time warning in the Console.
