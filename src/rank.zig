/// Ranks used for the cards.
pub const Hierarchy = enum(u4) {
    NoRank,
    Joker,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace,

    /// Checks if the ranks are equal.
    pub fn isRankEqual(currentRank: Hierarchy, desiredRank: Hierarchy) bool {
        return if (currentRank == desiredRank) true else false;
    }
};
