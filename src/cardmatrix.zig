const card = @import("card.zig");
const std = @import("std");

/// Maximum default number of cards in a game.
const MAX_CARD_AMOUNT = 104;

/// Maximum default number of rows.
const MAX_ROWS = 4;

/// Maximum default number of columns per row.
const MAX_COLUMNS = 26;

/// Initializes and returns a matrix with default dimensions and empty cards.
pub fn init() Matrix {
    return Matrix{
        .matrix = [_]card.CAttributes{undefined} ** MAX_CARD_AMOUNT,
        .rows = MAX_ROWS,
        .columns = MAX_COLUMNS,
        .row_last_index = [_]i8{-1} ** MAX_ROWS,
    };
}

/// A matrix of cards arranged in rows and columns.
pub const Matrix = struct {
    matrix: [MAX_CARD_AMOUNT]card.CAttributes,
    rows: u8,
    columns: u8,
    row_last_index: [MAX_ROWS]i8, // tracks last used index in each row

    /// Resets teh matrix.
    pub fn reset(self: *Matrix) void {
        self.* = Matrix{
            .matrix = [_]card.CAttributes{undefined} ** MAX_CARD_AMOUNT,
            .rows = MAX_ROWS,
            .columns = MAX_COLUMNS,
            .row_last_index = [_]i8{-1} ** MAX_ROWS,
        };
    }

    /// Adds a card to the specified row.
    pub fn addCard(self: *Matrix, row: u8, newCard: card.CAttributes) !void {
        self.row_last_index[row] += 1;
        const idx: u8 = @intCast(self.row_last_index[row]);
        self.matrix[row * self.columns + idx] = newCard;
    }

    /// Removes the last card from the specified row.
    pub fn removeCard(self: *Matrix, row: u8) !void {
        if (self.row_last_index[row] >= 0) {
            self.row_last_index[row] -= 1;
        } else {
            std.debug.print("[Matrix] Row {} is already empty\n", .{row});
        }
    }

    /// Returns the card at the given row and column.
    /// Prints a warning if the row is empty.
    pub fn checkMatrix(self: *Matrix, row: u8, column: u8) !card.CAttributes {
        if (self.row_last_index[row] < 0) {
            std.debug.print("[Matrix] Row {} is empty; value may be uninitialized\n", .{row});
        }
        return self.matrix[row * self.columns + column];
    }
};
