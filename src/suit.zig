const std = @import("std");
/// Suits used for the cards
pub const Group = enum(u4) {
    Empty,
    Heart,
    Spade,
    Club,
    Diamond,

    /// Checks if the suits are equal.
    pub fn isSuitEqual(currentSuit: Group, desiredSuit: Group) bool {
        return if (currentSuit == desiredSuit) true else false;
    }
};

test "equal suit pass" {
    const suit_one = Group.Club;
    const suit_two = Group.Club;

    try std.testing.expect(Group.isSuitEqual(suit_one, suit_two));
}
