/// Suits used for the cards.
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
