import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 高德地图Widget，支持丰富自定义参数
class AmapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final bool showMarker;
  final String? markerLabel;
  final double height;
  final double width;
  final void Function(double lat, double lng)? onMapTap;
  final bool showTrafficLayer; // 新增参数
  final bool showToolBar; // 新增：缩放工具条
  final bool showScale; // 新增：比例尺
  final bool showGeolocation; // 新增：定位按钮
  final List<List<double>>? polygonPath; // 新增：多边形经纬度数组
  final bool showDrawTools; // 新增：是否显示绘制工具按钮

  const AmapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoomLevel = 15,
    this.showMarker = true,
    this.markerLabel,
    this.height = 200,
    this.width = double.infinity,
    this.onMapTap,
    this.showTrafficLayer = false, // 默认不显示
    this.showToolBar = true,
    this.showScale = true,
    this.showGeolocation = true,
    this.polygonPath,
    this.showDrawTools = true, // 默认不显示
  });

  @override
  State<AmapWidget> createState() => _AmapWidgetState();
}

class _AmapWidgetState extends State<AmapWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..loadHtmlString(_buildMapHtml());
  }

  String _buildMapHtml() {
    // 使用用户提供的key和安全密钥
    final amapKey = '0ec49d3ec6aafff4bc085f06c1f1ba9a';
    final amapJsCode = '2c9ee61b57457dd9453f6e9675ae5bcd';
    final markerScript =
        widget.showMarker
            ? '''
        // 自定义Marker内容
        const markerContent = `<div class=\"custom-content-marker\">\n  <img src=\"//a.amap.com/jsapi_demos/static/demo-center/icons/dir-via-marker.png\">\n  <div class=\"close-btn\" onclick=\"clearMarker()\">X</div>\n</div>`;
        var marker = new AMap.Marker({
          position: new AMap.LngLat(${widget.longitude}, ${widget.latitude}),
          content: markerContent,
          offset: new AMap.Pixel(-13, -30),
          map: map
        });
        map.add(marker);
        function clearMarker() {
          map.remove(marker);
        }
        // 自定义样式
        var style = document.createElement('style');
        style.innerHTML = `
        .custom-content-marker { position: relative; width: 25px; height: 34px; }
        .custom-content-marker img { width: 100%; height: 100%; }
        .custom-content-marker .close-btn { position: absolute; top: -6px; right: -8px; width: 15px; height: 15px; font-size: 12px; background: #ccc; border-radius: 50%; color: #fff; text-align: center; line-height: 15px; box-shadow: -1px 1px 1px rgba(10,10,10,.2); cursor: pointer; }
        .custom-content-marker .close-btn:hover { background: #666; }
        `;
        document.head.appendChild(style);
      '''
            : '';
    final polygonScript =
        (widget.polygonPath != null && widget.polygonPath!.length >= 3)
            ? '''
        var polygon = new AMap.Polygon({
          path: [
            ${widget.polygonPath!.map((p) => '[${p[0]}, ${p[1]}]').join(',\n            ')}
          ],
          fillColor: '#ccebc5',
          strokeColor: '#2b8cbe',
          strokeWeight: 2,
          fillOpacity: 0.5,
          strokeOpacity: 0.9,
          strokeStyle: 'dashed',
          strokeDasharray: [5, 5],
        });
        map.add(polygon);
        polygon.on('mouseover', function() {
          polygon.setOptions({ fillOpacity: 0.7, fillColor: '#7bccc4' });
        });
        polygon.on('mouseout', function() {
          polygon.setOptions({ fillOpacity: 0.5, fillColor: '#ccebc5' });
        });
      '''
            : '';
    final trafficScript =
        widget.showTrafficLayer
            ? '''
        var traffic = new AMap.TileLayer.Traffic({
          autoRefresh: true,
          interval: 180
        });
        map.add(traffic);
      '''
            : '';
    final toolBarScript =
        widget.showToolBar
            ? '''
        AMap.plugin('AMap.ToolBar', function() {
          var toolbar = new AMap.ToolBar({
            position: 'LT', // 左上角
            offset: new AMap.Pixel(10, 60) // 下移避免logo遮挡
          });
          map.addControl(toolbar);
        });
      '''
            : '';
    final scaleScript =
        widget.showScale
            ? '''
        AMap.plugin('AMap.Scale', function() {
          var scale = new AMap.Scale();
          map.addControl(scale);
        });
      '''
            : '';
    final geolocationScript =
        widget.showGeolocation
            ? '''
        AMap.plugin('AMap.Geolocation', function() {
          var geolocation = new AMap.Geolocation({
            enableHighAccuracy: true,
            timeout: 10000,
            buttonPosition: 'RB', // 右下角
            buttonOffset: new AMap.Pixel(10, 80),
            zoomToAccuracy: true,
            showCircle: true
          });
          map.addControl(geolocation);
          // 自动定位到当前位置
          geolocation.getCurrentPosition(function(status, result) {
            if (status === 'complete') {
              map.setCenter(result.position);
            }
          });
        });
      '''
            : '';
    final drawToolsHtml = widget.showDrawTools
        ? '''
      <div id=\"draw-tools\" style=\"position:absolute;top:12px;right:12px;z-index:9999;background:rgba(255,255,255,0.97);border-radius:10px;padding:8px 6px;box-shadow:0 2px 8px #0001;min-width:120px;max-width:70vw;\">
        <div style=\"display:flex;flex-direction:column;gap:6px;\">
          <button class=\"draw-btn\" onclick=\"drawPolyline()\">线段</button>
          <button class=\"draw-btn\" onclick=\"drawPolygon()\">多边形</button>
          <button class=\"draw-btn\" id=\"finishBtn\" style=\"background:#1791fc;color:#fff;display:none;\" onclick=\"finishDraw()\">完成</button>
        </div>
      </div>
      <style>
        .draw-btn { font-size:15px;padding:7px 0;border:none;border-radius:6px;background:#f3f3f3;margin:0; }
        .draw-btn:active { background:#e0e0e0; }
        @media (max-width: 500px) {
          #draw-tools { min-width:90px;max-width:90vw;padding:6px 2px; }
          .draw-btn { font-size:13px;padding:6px 0; }
        }
      </style>
    '''
        : '';
    final mouseToolScript = widget.showDrawTools
        ? '''
      AMap.plugin('AMap.MouseTool', function() {
        var mouseTool = new AMap.MouseTool(map);
        var drawing = false;
        var currentType = null;
        var finishBtn = null;
        var lastObj = null;
        function showFinishBtn() {
          if (!finishBtn) finishBtn = document.getElementById('finishBtn');
          if (finishBtn) finishBtn.style.display = '';
        }
        function hideFinishBtn() {
          if (!finishBtn) finishBtn = document.getElementById('finishBtn');
          if (finishBtn) finishBtn.style.display = 'none';
        }
        window.drawPolyline = function() {
          mouseTool.polyline({
            strokeColor: "#3366FF",
            strokeOpacity: 1,
            strokeWeight: 2,
            strokeStyle: "solid"
          });
          drawing = true;
          currentType = 'polyline';
          showFinishBtn();
        };
        window.drawPolygon = function() {
          mouseTool.polygon({
            strokeColor: "#FF33FF",
            strokeOpacity: 1,
            strokeWeight: 2,
            fillColor: '#1791fc',
            fillOpacity: 0.3,
            strokeStyle: "solid"
          });
          drawing = true;
          currentType = 'polygon';
          showFinishBtn();
        };
        window.finishDraw = function() {
          if (drawing) {
            mouseTool.close(false); // 结束当前绘制，但不清除图形
            drawing = false;
            currentType = null;
            hideFinishBtn();
          }
        };
        mouseTool.on('draw', function(event) {
          lastObj = event.obj; // 保留最后绘制的对象
          drawing = false;
          currentType = null;
          hideFinishBtn();
        });
      });
    '''
        : '';
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
      <style>html, body, #container { height: 100%; margin: 0; padding: 0; }\n#draw-tools button{font-size:14px;padding:6px 0;}</style>
      <script type=\"text/javascript\">
        window._AMapSecurityConfig = {
          securityJsCode: '$amapJsCode'
        };
      </script>
      <script src=\"https://webapi.amap.com/maps?v=2.0&key=$amapKey&plugin=AMap.ToolBar,AMap.Scale,AMap.Geolocation,AMap.MouseTool\"></script>
    </head>
    <body>
      <div id=\"container\" style=\"width:100%;height:100%\"></div>
      $drawToolsHtml
      <script type=\"text/javascript\">
        var map = new AMap.Map("container", {
          center: [${widget.longitude}, ${widget.latitude}],
          zoom: ${widget.zoomLevel},
          viewMode: '2D'
        });
        $toolBarScript
        $geolocationScript
        $scaleScript
        $trafficScript
        $markerScript
        $polygonScript
        $mouseToolScript
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }
}
