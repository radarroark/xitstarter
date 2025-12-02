const std = @import("std");
const xit = @import("xit");
const rp = xit.repo;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const cwd_path = try std.process.getCwdAlloc(allocator);
    defer allocator.free(cwd_path);

    const work_path = try std.fs.path.resolve(allocator, &.{ cwd_path, "myrepo" });
    defer allocator.free(work_path);

    var repo = try rp.Repo(.xit, .{}).init(allocator, .{ .path = work_path });
    defer repo.deinit();

    try repo.addConfig(allocator, .{ .name = "user.name", .value = "mr magoo" });
    try repo.addConfig(allocator, .{ .name = "user.email", .value = "mister@magoo" });

    const readme = try repo.core.work_dir.createFile("README.md", .{});
    defer readme.close();
    try readme.writeAll("hello, world!");
    try repo.add(allocator, &.{"README.md"});

    const oid = try repo.commit(allocator, .{ .message = "initial commit" });
    std.debug.print("committed with object id: {s}\n", .{oid});
}
