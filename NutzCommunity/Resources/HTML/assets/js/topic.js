
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
        var likeNum = parseInt(like.html(),10);

        //点击之前没有like
        if(checked.val() == 0){
            img.attr("src", "checkbox_good_check.png");
            like.html((likeNum + 1) + "赞");
            checked.val(1);
        }else{
            img.attr("src", "checkbox_good_normal.png");
            like.html((likeNum - 1) + "赞");
            checked.val(0);
        }
    }
}

/**
 *  回复评论
 *
 *  @param authorName 评论者loginname
 *  @param replyId    回复Id号
 *
 */
function reply(authorName, replyId){
    console.log(authorName);
    window.nutz.callHandler("replyTopic", {"authorName" : authorName, "replyId" : replyId}, function(data){
        addReply(data);
    });
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

function bindFontScaleTool(reply){
    var toolbar = "<div class='codetool'>" +
                    "<button onclick='scaleCodeFontSize(this, false);'>缩小</button>" +
                    "<button onclick='scaleCodeFontSize(this, true);'>放大</button>" +
                 "</div>";
    if(reply){
        $(reply).find('pre').each(function(i){
            $(this).append(toolbar);
            $(this).attr("show_ctrl","0")
            $(this).bind('click', function(){
                showCodeTool($(this));
            });
        });
    }else{
        $('pre').each(function(i){
            $(this).append(toolbar);
            $(this).attr("show_ctrl","0")
            $(this).bind('click', function(){
                showCodeTool($(this));
            });
        });
    }
}

/**
 *  缩放代码块字体
 *
 *  @param preBlock pre div
 *
 */
function showCodeTool(pre){
    //缩放控制
    var ctrl = pre.find(".codetool");
    
    //正在显示 缩放控制
    if(pre.attr("show_ctrl") == 1){
        pre.attr("show_ctrl", "0");
        ctrl.hide();
    }else{
        pre.attr("show_ctrl", "1");
        ctrl.show();
    }
}

function scaleCodeFontSize(btn, zoom){
    //父级
    var pre = $(btn).parent().parent().find("code");
    //父级字体大小
    var fontSize = parseFloat(pre.css('font-size') , 10);
    // 改变字体大小
    if(zoom){
        fontSize += 1;
    }else{
        fontSize -= 1;
    }
    pre.css("font-size", fontSize + "px");
}
