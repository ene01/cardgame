//! Player state containing hand, discard deck, and tableau.

const std = @import("std");
const Card = @import("card.zig");
const Cardmatrix = @import("cardmatrix.zig");
const Deck = @import("deck.zig");
const testing = std.testing;
const debug = std.debug;

pub const Player = @This();

hand: Deck,
/// The deck the player must clear to win.
discard_deck: Deck,
/// Column-based layout similar to solitaire.
tableau: Cardmatrix,
is_playing: bool,

/// Creates a player with empty hand, discard deck, and tableau.
pub fn init(
    gpa: std.mem.Allocator,
    hand_size: usize,
    discard_size: usize,
    columns: u16,
    column_deck_size: usize,
) !Player {
    return Player{
        .hand = try Deck.init(gpa, hand_size),
        .discard_deck = try Deck.init(gpa, discard_size),
        .tableau = try Cardmatrix.init(gpa, columns, column_deck_size),
        .is_playing = true,
    };
}

/// Frees all dynamic storage.
pub fn deinit(self: *Player) void {
    self.hand.deinit();
    self.tableau.deinit();
    self.discard_deck.deinit();
}

/// Adds a card to the hand.
pub fn addToHand(self: *Player, new_card: Card) !void {
    try self.hand.addCard(new_card);
}

/// Adds a card to the discard deck.
pub fn addToDiscardDeck(self: *Player, new_card: Card) !void {
    try self.discard_deck.addCard(new_card);
}

/// Adds a card to a tableau column.
pub fn addToColumn(self: *Player, new_card: Card, column_index: usize) !void {
    try self.tableau.addCard(@intCast(column_index), new_card);
}

/// Removes one matching card from the hand.
pub fn removeCardFromHand(self: *Player, index: usize) Card {
    return self.hand.removeCard(index);
}

/// Removes one matching card from the discard deck.
pub fn removeCardFromDiscardDeck(self: *Player, index: usize) Card {
    return self.discard_deck.removeCard(index);
}

/// Removes all matching cards from the hand.
pub fn removeMultCardsFromHand(self: *Player, card: Card) usize {
    return self.hand.removeMultipleCardsByID(card);
}

/// Removes all matching cards from the discard deck.
pub fn removeMultCardsFromDiscardDeck(self: *Player, card: Card) usize {
    return self.discard_deck.removeMultipleCardsByID(card);
}

/// Removes the last card from a tableau column.
pub fn removeCardFromColumn(self: *Player, column: usize, index: usize) Card {
    return self.tableau.removeCard(column, index);
}

/// Removes the last card from a tableau column.
pub fn removeMultCardsFromColumn(self: *Player, column: usize, card: Card) Card {
    return self.tableau.removeCardsByID(column, card);
}

test "player initiation" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    try testing.expectEqual(4, player_one.tableau.matrix.items.len);
    try testing.expectEqual(0, player_one.discard_deck.len());
    try testing.expectEqual(0, player_one.hand.len());
    try testing.expect(player_one.is_playing);
}

test "add card to hand" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try player_one.addToHand(card_one);

    try testing.expectEqual(1, player_one.hand.cards.items.len);
    try testing.expectEqual(card_one, player_one.hand.cards.items[0]);
}

test "add card to column" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_three = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };

    try player_one.addToColumn(card_one, 0);
    try player_one.addToColumn(card_two, 1);
    try player_one.addToColumn(card_three, 2);
    try player_one.addToColumn(card_four, 3);

    try testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[2].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);

    try testing.expectEqual(card_one, player_one.tableau.matrix.items[0].cards.items[0]);
    try testing.expectEqual(card_two, player_one.tableau.matrix.items[1].cards.items[0]);
    try testing.expectEqual(card_three, player_one.tableau.matrix.items[2].cards.items[0]);
    try testing.expectEqual(card_four, player_one.tableau.matrix.items[3].cards.items[0]);
}

test "add card to discard deck" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try player_one.addToDiscardDeck(card_one);

    try testing.expectEqual(1, player_one.discard_deck.cards.items.len);
    try testing.expectEqual(card_one, player_one.discard_deck.cards.items[0]);
}

test "remove from discard deck" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try player_one.discard_deck.cards.append(alloc, card_one);

    try testing.expectEqual(1, player_one.discard_deck.cards.items.len);
    try testing.expectEqual(card_one, player_one.discard_deck.cards.items[0]);

    const removed_card = player_one.removeCardFromDiscardDeck(0);

    try testing.expectEqual(card_one, removed_card);
}

test "remove from hand" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try player_one.hand.cards.append(alloc, card_one);

    try testing.expectEqual(1, player_one.hand.len());
    try testing.expectEqual(card_one, player_one.hand.lookupByIndex(0));

    const removed_card = player_one.removeCardFromHand(0);
    try testing.expectEqual(card_one, removed_card);
}

test "remove multiple from hand" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };

    // four equal, one different.
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_two);

    try testing.expectEqual(5, player_one.hand.cards.items.len);

    const amount_removed = player_one.removeMultCardsFromHand(card_one);

    try testing.expectEqual(1, player_one.hand.cards.items.len);
    try testing.expectEqual(4, amount_removed);
}

test "remove multiple from discard deck" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };

    // four equal, one different.
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_two);

    try testing.expectEqual(5, player_one.discard_deck.cards.items.len);

    const amount_removed = player_one.removeMultCardsFromDiscardDeck(card_one);

    try testing.expectEqual(1, player_one.discard_deck.cards.items.len);
    try testing.expectEqual(4, amount_removed);
}

test "remove card from column" {
    const alloc = testing.allocator;

    var player_one = try Player.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_three = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };

    try player_one.tableau.matrix.items[0].cards.append(alloc, card_one);
    try player_one.tableau.matrix.items[1].cards.append(alloc, card_two);
    try player_one.tableau.matrix.items[2].cards.append(alloc, card_three);
    try player_one.tableau.matrix.items[3].cards.append(alloc, card_four);

    try testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[2].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);

    try testing.expectEqual(card_one, player_one.tableau.matrix.items[0].cards.items[0]);
    try testing.expectEqual(card_two, player_one.tableau.matrix.items[1].cards.items[0]);
    try testing.expectEqual(card_three, player_one.tableau.matrix.items[2].cards.items[0]);
    try testing.expectEqual(card_four, player_one.tableau.matrix.items[3].cards.items[0]);

    const removed_card = player_one.removeCardFromColumn(2, 0);

    try testing.expectEqual(card_three, removed_card);

    try testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try testing.expectEqual(0, player_one.tableau.matrix.items[2].cards.items.len);
    try testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);
}
