const std = @import("std");
const xit = @import("xit");
const rp = xit.repo;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var work_dir = try std.fs.cwd().makeOpenPath("myrepo", .{});
    defer work_dir.close();

    var repo = try rp.Repo(.xit, .{}).init(allocator, .{ .cwd = work_dir }, ".");
    defer repo.deinit();

    try repo.addConfig(allocator, .{ .name = "user.name", .value = "mr magoo" });
    try repo.addConfig(allocator, .{ .name = "user.email", .value = "mister@magoo" });

    const readme = try work_dir.createFile("README.md", .{});
    defer readme.close();
    try readme.writeAll("hello, world!");
    try repo.add(allocator, &.{"README.md"});

    const oid = try repo.commit(allocator, .{ .message = "initial commit" });
    std.debug.print("committed with object id: {s}\n", .{oid});
}
