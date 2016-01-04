Array.prototype.contains = function(item){
  return RegExp("\\b"+item+"\\b").test(this);
};
// ios webview js bridge
function JSBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        callback(WebViewJavascriptBridge);
    } else {
        document.addEventListener('WebViewJavascriptBridgeReady', function() {
                                  window.nutz = WebViewJavascriptBridge;
                                  callback(WebViewJavascriptBridge);
                                  }, false);
    }
}


/**
 * 点赞或取消点赞
 * @param postUser 发布回复的人
 * @param replyId  回复id
 */
function like(postUser, replyId){
    //是不是本人
    nutz.callHandler("likeReply", {"postUser" : postUser, "replyId" : replyId}, function(data){
        likeCallback(data.result, data.replyId);
    });
}

//点击like的回调
function likeCallback(result, replyId){
    if(result){
        var checked = $("#chk_" + replyId);
        var img = $("#like_img_" + replyId);
        var like = $("#like_" + replyId);
        var likeNum = parseInt(like.html());

        //点击之前没有like
        if(checked.val() == 0){
            img.attr("src", "checkbox_good_check.png");
            like.html(likeNum + 1);
            checked.val(1);
        }else{
            img.attr("src", "checkbox_good_normal.png");
            like.html(likeNum - 1);
            checked.val(0);
        }
    }
}

/**
 * 回复某人的评论
 * @param authorName 评论作者用户名
 * @param replyId 对应的回复 id
 */
function reply(authorName, replyId){
    window.nutz.replyComment(authorName, replyId);
}

function topicType(isTop, origin){
    if(isTop){
        return "置顶";
    }else if(origin == "ask"){
        return "问答";
    }else if(origin == "news"){
        return "新闻";
    }else if(origin == "share"){
        return "分享";
    }else if(origin == "job"){
        return "招聘";
    }else if(origin == "nb"){
        return "灌水";
    }else if(origin == "shortit"){
            return "短点";
    }else{
        return "其他"
    }
}