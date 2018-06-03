<link rel="stylesheet" href="{$systemurl}modules/servers/v2ray/templates/LegendSock/stylesheets/style.css">
<link rel="stylesheet" href="{$systemurl}modules/servers/v2ray/templates/LegendSock/stylesheets/font-awesome.min.css">
<script src="{$systemurl}modules/servers/v2ray/templates/LegendSock/javascripts/layer/layer.js"></script>
<script src="{$systemurl}modules/servers/v2ray/templates/LegendSock/javascripts/qrcode.js"></script>
<script src="{$systemurl}modules/servers/v2ray/templates/LegendSock/javascripts/common.js"></script>
<script src="{$systemurl}modules/servers/v2ray/templates/LegendSock/javascripts/chart.js"></script>

<style>
    #QRCode_HTML {
        display: none;
    }
    #QRCode {
        padding: 10px;
    }
    .layui-layer-content > p {
         color: #666;
         font-size: 12px;
         margin: 0 0 10px 0;
         text-align: center;
     }
</style>

<script>
    {if $chart|@count neq 0}
    var myChart = {
        type: 'line',
        data: {
            labels: [{foreach $chart['upload'] as $key => $value}{$key},{/foreach}],
            datasets: [{
                label: "{$LS_LANG['chart']['upload']} ( MB )",
                data: [{foreach $chart['upload'] as $value}{(($value) / 1048576)|round:2},{/foreach}],
                fill: false,
                borderDash: [5, 5],
                borderColor: "rgba(185,198,192,1)",
                backgroundColor: "rgba(185,198,192,0.2)",
                pointBorderColor: "rgba(222,137,171,1)",
                pointBackgroundColor: "rgba(222,137,171,1)",
                pointBorderWidth: 1
            }, {
                label: "{$LS_LANG['chart']['download']} ( MB )",
                data: [{foreach $chart['download'] as $value}{(($value) / 1048576)|round:2},{/foreach}],
                fill: false,
                borderDash: [5, 5],
                borderColor: "rgba(222,137,171,1)",
                backgroundColor: "rgba(222,137,171,0.2)",
                pointBorderColor: "rgba(185,198,192,1)",
                pointBackgroundColor: "rgba(185,198,192,1)",
                pointBorderWidth: 1
            }]
        }
    };
    {/if}
    window.onload = function() {
        var chart = document.getElementById("myChart").getContext("2d");
        window.myLine = new Chart(chart, myChart);
    };
    $(document).ready(function($) {
        // 声明一个 QRCode，选择 id 为 qrcode 的元素
        var qrcode = new QRCode("QRCode", {
            text: "default",
            width: 280,
            height: 280,
            colorDark : "#000",
            colorLight : "#FFF",
            correctLevel : QRCode.CorrectLevel.L
        });
        // 定义 name 为 qrcode 的元素按下时的事件
        $("[name='qrcode']").on('click',function() {
            qrcode.clear(); // 清空图像
            // QR 的名字
            qrname = $(this).attr('data-qrname');
            // QR 的主体内容
            var qrcontent = $(this).attr('data-qrcode');
            // 判断是 Shadowsocks 还是其他的二维码
            switch (qrname) {
                case 'Shadowsocks':
                    // 如果是 Shadowsocks
                    qrcontent = 'ss://' + window.btoa(qrcontent);
                    break;
                case 'ShadowsocksR':
                    // 如果是 ShadowsocksR
                    qrcontent = 'ssr://' + window.btoa(qrcontent);
                    break;
                case 'V2ray':
                    qrcontent = qrcontent;
                    break;
                default:
                    // 默认什么都不做
                    break;
            }
            
            if ($(this).attr('data-client')) {
                qrname = qrname + $(this).attr('data-client');
            }
            // 生成另一个图像
            qrcode.makeCode(qrcontent);
            // 弹出层
            layer.open({
                type: 1,
                title: $(this).attr('title'),
                shade: [0.8, '#000'],
                skin: 'layui-layer-demo',
                closeBtn: 1,
                shift: 2,
                shadeClose: true,
                content: document.getElementById('QRCode_HTML').innerHTML + '<p>{$LS_LANG['qrcode']['0']} ' + qrname + ' {$LS_LANG['qrcode']['1']}</p>'
            });
        });
        $("[name='v2raylink']").on('click', function() {
            layer.open({
                type: 1,
                title: $(this).attr('title'),
                shade: [0.8, '#000'],
                skin: 'layui-layer-demo',
                closeBtn: 1,
                shift: 2,
                shadeClose: true,
                content: '<p style="word-wrap:break-word;text-align:left;padding: 15px">' + $(this).attr('data-link') + '</p>'
            })
        });
        $("[name='guiconfig']").on('click',function() {
            function download(fileName, blob){
                var aLink = document.createElement('a');
                var evt = document.createEvent("MouseEvents");
                evt.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                aLink.download = fileName;
                aLink.href = URL.createObjectURL(blob);
                aLink.dispatchEvent(evt);
            }

            function stringToBlob(text) {
                var u8arr = new Uint8Array(text.length);
                for (var i = 0, len = text.length; i < len; ++i) {
                    u8arr[i] = text.charCodeAt(i);
                }
                var blob = new Blob([u8arr]);
                return blob;
            }
            var json_content = $(this).attr('data-guiconfig');
            json_content = window.atob(json_content);
            json_content = json_content.replace(/\r\n|\n/g,"");
            json_content = json_content.replace(/\'/ig,"\"");
            var blob = stringToBlob(JSON.stringify(JSON.parse(json_content),null,2));
            download('gui-config.json', blob);
        });
    });
</script>

<div id="QRCode_HTML">
    <div id="QRCode" style="width: 300px;height: 300px;"></div>
</div>

<div class="row" id="LS">
    {if $notice|@count neq 0}
        <div class="col-md-12">
            <div class="alert alert-warning alert-dismissible fade in" role="alert">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>
                {if $notice|@count eq 1}
                    {$notice[0]|trim}
                {else}
                    <ul style="padding: 0px;">
                        {foreach $notice as $value}
                            <li>{$value|trim}</li>
                        {/foreach}
                    </ul>
                {/if}
            </div>
        </div>
    {/if}

    <div class="legend-responsive">
        <div class="col-md-4">
            <div class="box-sm">
                <div class="box-sm-title">
                    {$LS_LANG['product']['head']}
                </div>
                <div>
                    <span class="box-sm-font">{$product}</span>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="box-sm">
                <div class="box-sm-title">
                    {$LS_LANG['nextduedate']}
                </div>
                <div>
                    <span class="box-sm-font">{$nextduedate}</span>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="box-sm">
                <div class="box-sm-title">
                    {$LS_LANG['traffic']['head']}
                </div>
                <div>
                    <span class="box-sm-font">{if ($info['u'] + $info['d']) > 1073741824}{(($info['u'] + $info['d']) / 1073741824)|round:2} GB{else}{(($info['u'] + $info['d']) / 1048576)|round:2} MB{/if}</span><span class="box-sm-font-sm"> / {if (($info['transfer_enable'] - ($info['u'] + $info['d']))) > 1073741824}{(($info['transfer_enable'] - ($info['u'] + $info['d'])) / 1073741824)|round:2} GB{else}{(($info['transfer_enable'] - ($info['u'] + $info['d'])) / 1048576)|round:2} MB{/if}</span>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-12">
        <ul class="nav nav-tabs" role="tablist" style="margin-bottom: 18px;">
            <li role="presentation" class="active"><a href="#home" aria-controls="home" role="tab" data-toggle="tab">{$LS_LANG['page']['home']}</a></li>
            <li role="presentation"><a href="#other" aria-controls="other" role="tab" data-toggle="tab">{$LS_LANG['page']['other']}</a></li>
        </ul>
    </div>

    <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="home">
            <div class="col-md-12">
                <div class="panel panel-info">
                    <div class="panel-heading">
                        <h3 class="panel-title">{$LS_LANG['product']['title']}</h3>
                    </div>
                    <div class="legend-responsive">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>{$LS_LANG['product']['id']}</th>
                                <th>{$LS_LANG['product']['v2ray_uuid']}</th>
                                <th>{$LS_LANG['product']['v2ray_alter_id']}</th>
                                <th>{$LS_LANG['product']['v2ray_level']}</th>
                                <th>{$LS_LANG['product']['lastTime']}</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td style="width: 10%;">{$serviceid}</td>
                                <td style="width: 45%;"><span id="userId" onclick="javascript:document.getElementById('userId').innerHTML='{$info['v2ray_uuid']}';">{$LS_LANG['product']['show']}</span></td>
                                <td style="width: 10%;">{$info['v2ray_alter_id']}</td>
                                <td style="width: 10%;">{$info['v2ray_level']}</td>
                                <td style="width: 25%;">{$info['t']|date_format:'%Y-%m-%d, %H:%M'}</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <!--div class="panel panel-info">
                    <div class="panel-heading">
                        <h3 class="panel-title">{$LS_LANG['plugin']['title']}</h3>
                    </div>
                    <div class="legend-responsive">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>{$LS_LANG['plugin']['guiconfig']}</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td style="min-width: 190px; width: 25%;">
                                    <div class="btn-group btn-group-xs" role="group" aria-label="Extra-small button group">
                                        <button type="button" class="btn btn-info btn-xs autoset" name="guiconfig" data-guiconfig="{$guiconfig['ss']}">
                                            <span class="glyphicon glyphicon-send" aria-hidden="true"></span> {$LS_LANG['plugin']['general']}
                                        </button>
                                        <button type="button" class="btn btn-info btn-xs autohides" name="guiconfig" data-guiconfig="{$guiconfig['ssr']}">
                                            <span class="glyphicon glyphicon-export" aria-hidden="true"></span> {$LS_LANG['plugin']['ssr']}
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div-->
                <div class="panel panel-info">
                    <div class="panel-heading">
                        <span class="badge">{$LS_LANG['node']['head']['0']} {$node|@count} {$LS_LANG['node']['head']['1']}</span>
                        <h3 class="panel-title">{$LS_LANG['node']['title']}</h3>
                    </div>
                    <div class="legend-responsive">
                        <table class="table">
                            <thead>
                            <tr>
                                <th style="width: 10%;">{$LS_LANG['node']['name']}</th>
                                <th style="width: 20%;">{$LS_LANG['node']['host']}</th>
                                <th style="width: 10%;">{$LS_LANG['node']['port']}</th>
                                <th style="width: 10%;">{$LS_LANG['node']['security']}</th>
                                <th style="width: 20%;">{$LS_LANG['node']['remarks']}</th>
                                <th style="width: 30%;">{$LS_LANG['node']['qrcode']}</th>
                            </tr>
                            </thead>
                            <tbody>
                            {if $node|@count neq 0}
                                {foreach $node as $key => $value}
                                    {$value=("|"|explode:$value)}
                                    <tr>
                                        <td>{$value[0]|trim}</td>
                                        <td>{$value[1]|trim}</td>
                                        <td>{$value[2]|trim}</td>
                                        <td>{$value[3]|trim}</td>
                                        <td>{$value[4]|trim}</td>
                                        <td>
                                            <div class="btn-group btn-group-xs" role="group" aria-label="Extra-small button group">
                                                <button type="button" class="btn btn-info btn-xs autohides" data-qrname="V2ray" data-qrcode="{$extend[$key]['v2rayOtherUrl']}" data-client="Android" title="{$LS_LANG['node']['v2ray']['title']}" name="qrcode">
                                                    <span class="fa fa-qrcode" aria-hidden="true"></span>
                                                </button>
                                            </div>
                                            <div class="btn-group btn-group-xs" role="group" aria-label="Extra-small button group">
                                                <button type="button" class="btn btn-info btn-xs autoset" data-qrname="V2ray" data-link="{$extend[$key]['v2rayOtherUrl']}" data-client="iOS" title="{$LS_LANG['node']['v2ray']['titleUri']}" name="v2raylink">
                                                    <span class="glyphicon glyphicon-link" aria-hidden="true"></span> {$LS_LANG['node']['v2ray']['importUri']}
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                {/foreach}
                            {/if}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div role="tabpanel" class="tab-pane" id="other">
            <div class="col-md-12">
                {if $addition}
                    <div class="alert alert-info alert-dismissible fade in" role="alert">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 style="margin-top: 0; font-weight: bold;"><span class="glyphicon glyphicon-heart" aria-hidden="true"></span> {$LS_LANG['traffic']['title']}</h4>
                        <p style="font-size: 15px;">{$LS_LANG['traffic']['tips']['0']}</p>
                        <p style="font-size: 12px;">{$LS_LANG['traffic']['tips']['1']} <span style="font-weight: bold; color: red;">{$serviceid}</span> {$LS_LANG['traffic']['tips']['2']}</p>
                        <p style="margin-top: 10px;">
                            <button type="button" class="btn btn-default" onclick="javascript:if (confirm('{$LS_LANG['traffic']['confirm']}')) window.location.href='{$systemurl}cart.php?a=add&pid=2';">{$LS_LANG['traffic']['order']}</button>
                        </p>
                    </div>
                {/if}
                {if $chart|@count neq 0}
                    <div class="panel panel-info">
                        <div class="panel-heading">
                            <span class="badge" title="{$LS_LANG['chart']['date']}">{$chart['date']|date_format:'%Y-%m-%d'}</span>
                            <h3 class="panel-title">{$LS_LANG['chart']['title']}</h3>
                        </div>
                        <div class="panel-body">
                            <canvas id="myChart"></canvas>
                        </div>
                    </div>
                {/if}
                {if $resource|@count neq 0}
                    <div class="panel panel-info">
                        <div class="panel-heading">
                            <h3 class="panel-title">{$LS_LANG['resource']}</h3>
                        </div>
                        <div class="list-group">
                            {foreach $resource as $value}
                                {$value=("|"|explode:$value)}
                                <a href="{$value[1]|trim}" class="list-group-item">
                                    <h4 class="list-group-item-heading">{$value[0]|trim}</h4>
                                    <p class="list-group-item-text">{$value[2]|trim}</p>
                                </a>
                            {/foreach}
                        </div>
                    </div>
                {/if}
            </div>
            {if $chart|@count neq 0}
                <div class="col-md-12">
                    <div class="alert alert-info" role="alert" style="text-align: center; font-size: 12px">
                        {$LS_LANG['chart']['tips']}
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>