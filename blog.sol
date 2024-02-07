// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Blog {
    struct Post {
        uint32 id;
        string title;
        string content;
        address author;
        uint32 createdAt; // 使用 uint32 类型
    }

    struct Comment {
        uint32 id;
        uint32 postId; // 使用 uint32 类型
        string content;
        address author;
        uint32 createdAt; // 使用 uint32 类型
    }

    Post[] public posts;
    Comment[] public comments;
    mapping(uint32 => uint32[]) public commentsByPostId; // postId -> commentIds, 使用 uint32 类型
    mapping(address => uint32[]) public postsByAuthor; // 使用 uint32 类型
    mapping(address => string) private nicknames;

    // 事件
    event PostCreated(uint32 id, string title, address author, uint32 createdAt);
    event PostDeleted(uint32 id, address author);
    event CommentAdded(uint32 id, uint32 postId, string content, address author, uint32 createdAt);
    event CommentDeleted(uint32 id, uint32 postId, address author);
    event NicknameSet(address user, string nickname);
    event PostEdited(uint32 id, string title, address author);
    event CommentEdited(uint32 id, string content, address author);

    // 设置昵称，确保昵称非空
    function setNickname(string memory _nickname) public {
        require(bytes(_nickname).length > 0, "Nickname cannot be empty");
        nicknames[msg.sender] = _nickname;
        emit NicknameSet(msg.sender, _nickname);
    }

    // 创建新博客帖子
    function createPost(string memory _title, string memory _content) public {
        require(bytes(nicknames[msg.sender]).length > 0, "Author must set a nickname first.");
        uint32 postId = uint32(posts.length);
        posts.push(Post(postId, _title, _content, msg.sender, uint32(block.timestamp)));
        postsByAuthor[msg.sender].push(postId); 
        emit PostCreated(postId, _title, msg.sender, uint32(block.timestamp));
    }

    // 添加评论到帖子
    function addComment(uint32 _postId, string memory _content) public {
        require(bytes(nicknames[msg.sender]).length > 0, "Author must set a nickname first.");
        require(_postId < uint32(posts.length), "Post does not exist.");
        uint32 commentId = uint32(comments.length);
        comments.push(Comment(commentId, _postId, _content, msg.sender, uint32(block.timestamp)));
        commentsByPostId[_postId].push(commentId);
        emit CommentAdded(commentId, _postId, _content, msg.sender, uint32(block.timestamp));
    }

    // 删除评论
    function deleteComment(uint32 _commentId) public {
        require(_commentId < uint32(comments.length), "Comment does not exist.");
        require(msg.sender == comments[_commentId].author, "Only the author can delete this comment.");
        delete comments[_commentId];
        emit CommentDeleted(_commentId, comments[_commentId].postId, msg.sender);
    }

    // 获取特定帖子的所有评论ID
    function getCommentsByPostId(uint32 _postId) public view returns (uint32[] memory) {
        return commentsByPostId[_postId];
    }

    // 公开函数以获取特定地址的昵称
    function getNickname(address user) public view returns (string memory) {
        require(bytes(nicknames[user]).length > 0, "No nickname set for this address.");
        return nicknames[user];
    }

    // 获取所有博客帖子的数量
    function getPostsCount() public view returns (uint) {
        return posts.length;
    }

    // 获取特定作者的所有帖子
    function getPostsByAuthor(address _author) public view returns (uint32[] memory) {
        return postsByAuthor[_author];
    }

    // 删除帖子
    function deletePost(uint32 _postId) public {
        require(_postId < posts.length && _postId >= 0, "Post does not exist.");
        require(msg.sender == posts[_postId].author, "Only the author can delete this post.");
        delete posts[_postId];
        emit PostDeleted(_postId, msg.sender);
    }

    // 编辑帖子
    function editPost(uint32 _postId, string memory _newTitle, string memory _newContent) public {
        require(_postId < uint32(posts.length), "Post does not exist.");
        Post storage post = posts[_postId];
        require(msg.sender == post.author, "Only the author can edit this post.");

        post.title = _newTitle;
        post.content = _newContent;
        // 可以选择是否添加一个事件来记录帖子的编辑行为
        emit PostEdited(_postId, _newTitle, msg.sender);
    }

    // 编辑评论
    function editComment(uint32 _commentId, string memory _newContent) public {
        require(_commentId < uint32(comments.length), "Comment does not exist.");
        Comment storage comment = comments[_commentId];
        require(msg.sender == comment.author, "Only the author can edit this comment.");

        comment.content = _newContent;
        // 同样，可以选择是否添加一个事件来记录评论的编辑行为
        emit CommentEdited(_commentId, _newContent, msg.sender);
    }

}