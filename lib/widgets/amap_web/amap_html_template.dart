import '../../common/api_config.dart';

/// 高德地图 HTML 模板
/// 包含地理围栏功能的Web代码
class AmapHtmlTemplate {
  /// 生成基础的HTML模板
  static String generateMapHtml({
    String title = '地理围栏动态地图',
    bool showLegend = true,
    bool show3D = true,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://*.amap.com https://*.autonavi.com data: 'unsafe-inline' 'unsafe-eval';">
    <title>$title</title>
    <style>
        ${_generateCSS(showLegend: showLegend)}
    </style>
</head>
<body>
    <div class="map-container">
        ${_generateMapTitle(title)}
        ${showLegend ? _generateLegend() : ''}
        <div id="map"></div>
    </div>

    ${_generateSecurityConfig()}
    ${_generateAmapScript()}
    
    <script>
        ${_generateJavaScript(show3D: show3D)}
    </script>
</body>
</html>
    ''';
  }

  /// 生成CSS样式
  static String _generateCSS({bool showLegend = true}) {
    return '''
        body, html { 
            margin: 0; 
            padding: 0; 
            width: 100%; 
            height: 100%; 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .map-container { 
            position: relative; 
            width: 100%; 
            height: 100%; 
            overflow: hidden; 
        }
        .map-title { 
            position: absolute; 
            top: 10px; 
            left: 10px; 
            right: 10px; 
            background: rgba(255,255,255,0.9); 
            padding: 10px; 
            border-radius: 8px; 
            text-align: center; 
            font-weight: bold; 
            z-index: 1000; 
            font-size: 16px;
            color: #333;
        }
        #map { 
            width: 100%; 
            height: 100%; 
        }
        
        /* 隐藏或缩小高德地图logo */
        .amap-logo {
            display: none !important;
        }
        .amap-copyright {
            display: none !important;
        }
        .anchorBL {
            display: none !important;
        }
        .amap-logo-text {
            display: none !important;
        }
        /* 如果无法完全隐藏，则缩小 */
        .amap-logo img {
            transform: scale(0.3) !important;
            opacity: 0.3 !important;
        }
        
        ${showLegend ? '''
        .legend {
            position: absolute;
            bottom: 10px;
            left: 10px;
            background: rgba(255,255,255,0.9);
            padding: 10px;
            border-radius: 8px;
            z-index: 1001;
            font-size: 12px;
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin: 4px 0;
        }
        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            margin-right: 8px;
        }
        ''' : ''}
    ''';
  }

  /// 生成地图标题
  static String _generateMapTitle(String title) {
    return '<div class="map-title">$title</div>';
  }

  /// 生成图例
  static String _generateLegend() {
    return '''
        <div class="legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #ff4444;"></div>
                <span>圆形围栏</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #4444ff;"></div>
                <span>多边形围栏</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #44ff44;"></div>
                <span>当前位置</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #ffff44;"></div>
                <span>触发围栏</span>
            </div>
        </div>
    ''';
  }

  /// 生成安全配置
  static String _generateSecurityConfig() {
    // 高德地图Web API 2.0需要安全密钥配置
    // 重要：这里必须使用安全密钥(securityCode)，不是API Key
    return '''
    <script type="text/javascript">
        window._AMapSecurityConfig = {
            securityJsCode: '${ApiConfig.amapSecurityCode}',
        }
    </script>
    ''';
  }

  /// 生成高德地图脚本引用
  static String _generateAmapScript() {
    // 使用高德地图Web API 1.4版本，避免ORB错误
    return '''
    <script src="https://webapi.amap.com/maps?v=1.4.15&key=${ApiConfig.amapWebApiKey}"></script>
    ''';
  }

  /// 生成JavaScript代码
  static String _generateJavaScript({bool show3D = true}) {
    return '''
        let map;
        let currentLocationMarker;
        let geofenceOverlays = {};
        let currentLocation = [116.397827, 39.909613];
        
        // 坐标验证函数
        function validateCoordinates(lng, lat) {
            // 检查是否为有效数字
            if (typeof lng !== 'number' || typeof lat !== 'number' || 
                isNaN(lng) || isNaN(lat) || 
                !isFinite(lng) || !isFinite(lat)) {
                console.warn('Invalid coordinates detected:', lng, lat);
                // 返回北京天安门的默认坐标
                return [116.397827, 39.909613];
            }
            
            // 检查经纬度范围（中国境内大致范围）
            if (lng < 73 || lng > 135 || lat < 18 || lat > 54) {
                console.warn('Coordinates out of China range:', lng, lat);
                // 返回北京天安门的默认坐标
                return [116.397827, 39.909613];
            }
            
            return [lng, lat];
        }

        // 初始化地图和围栏
        function initializeMapWithGeofences(lng, lat, geofences) {
            // 验证并修正坐标
            var validCoords = validateCoordinates(lng, lat);
            lng = validCoords[0];
            lat = validCoords[1];
            
            currentLocation = [lng, lat];
            console.log('Initializing map with validated coordinates:', lng, lat);
            
            map = new AMap.Map("map", {
                ${show3D ? '''
                pitch: 0,
                viewMode: '2D',
                rotateEnable: false,
                pitchEnable: false,
                ''' : '''
                viewMode: '2D',
                rotateEnable: false,
                pitchEnable: false,
                '''}
                zoom: 16,
                rotation: 0,
                zooms: [3, 20],
                center: currentLocation,
                showIndoorMap: false,
                expandZoomRange: true,
                doubleClickZoom: true,
                dragEnable: true,
                zoomEnable: true,
                jogEnable: false,
                scrollWheel: true,
                touchZoom: true,
                keyboardEnable: false
            });

            // 添加地图控件
            addMapControls();
            
            // 绘制围栏
            drawGeofences(geofences);
            
            // 添加当前位置标记
            addCurrentLocationMarker(lng, lat);
            
            // 隐藏高德logo
            hideLogo();
            
            FlutterGeofence.postMessage('地图初始化完成');
        }

        function addMapControls() {
            // 只添加定位按钮，移除所有其他控件
            addLocationButton();
            // 添加刷新定位按钮
            addRefreshLocationButton();
        }

        // 添加自定义定位按钮
        function addLocationButton() {
            var locationButton = document.createElement('div');
            locationButton.innerHTML = '📍';
            locationButton.style.cssText = `
                position: absolute;
                right: 15px;
                bottom: 15px;
                width: 40px;
                height: 40px;
                background: white;
                border: 1px solid #ccc;
                border-radius: 6px;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                z-index: 1000;
                user-select: none;
                transition: all 0.2s;
            `;
            
            locationButton.onmouseover = function() {
                this.style.backgroundColor = '#f0f0f0';
                this.style.transform = 'scale(1.05)';
            };
            
            locationButton.onmouseout = function() {
                this.style.backgroundColor = 'white';
                this.style.transform = 'scale(1)';
            };
            
            locationButton.onclick = function() {
                centerToCurrentLocation();
            };
            
            // 添加到地图容器
            document.getElementById('map').appendChild(locationButton);
        }

        // 添加刷新定位按钮
        function addRefreshLocationButton() {
            var refreshButton = document.createElement('div');
            refreshButton.innerHTML = '🔄';
            refreshButton.style.cssText = `
                position: absolute;
                right: 15px;
                bottom: 65px;
                width: 40px;
                height: 40px;
                background: white;
                border: 1px solid #ccc;
                border-radius: 6px;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                z-index: 1000;
                user-select: none;
            `;
            
            refreshButton.onmouseover = function() {
                this.style.backgroundColor = '#f0f0f0';
            };
            
            refreshButton.onmouseout = function() {
                this.style.backgroundColor = 'white';
            };
            
            refreshButton.onclick = function() {
                refreshCurrentLocation();
            };
            
            // 添加到地图容器
            document.getElementById('map').appendChild(refreshButton);
        }

        // 隐藏高德地图logo和版权信息
        function hideLogo() {
            setTimeout(function() {
                // 多种方式隐藏logo
                var logoSelectors = [
                    '.amap-logo',
                    '.amap-copyright', 
                    '.anchorBL',
                    '.amap-logo-text',
                    'a[href*="amap.com"]',
                    'div[class*="logo"]',
                    'div[class*="copyright"]'
                ];
                
                logoSelectors.forEach(function(selector) {
                    var elements = document.querySelectorAll(selector);
                    elements.forEach(function(element) {
                        element.style.display = 'none';
                        element.style.visibility = 'hidden';
                        element.style.opacity = '0';
                    });
                });
                
                // 如果还有顽固的logo，用更强力的方法
                var mapContainer = document.getElementById('map');
                if (mapContainer) {
                    var observer = new MutationObserver(function(mutations) {
                        mutations.forEach(function(mutation) {
                            mutation.addedNodes.forEach(function(node) {
                                if (node.nodeType === 1) { // Element node
                                    var logoElements = node.querySelectorAll('a[href*="amap.com"], div[class*="logo"], div[class*="copyright"]');
                                    logoElements.forEach(function(element) {
                                        element.style.display = 'none';
                                    });
                                    
                                    // 检查节点本身
                                    if (node.href && node.href.includes('amap.com')) {
                                        node.style.display = 'none';
                                    }
                                }
                            });
                        });
                    });
                    
                    observer.observe(mapContainer, {
                        childList: true,
                        subtree: true
                    });
                }
            }, 500);
            
            // 延迟再次执行，确保logo被隐藏
            setTimeout(hideLogo, 2000);
        }

        // 定位到当前位置
        function centerToCurrentLocation() {
            if (currentLocation && currentLocation.length >= 2) {
                map.setCenter(currentLocation);
                map.setZoom(16);
                
                // 添加一个临时的定位成功提示
                showLocationMessage('已定位到当前位置');
            } else {
                showLocationMessage('正在获取位置信息...');
                // 触发重新获取位置
                FlutterGeofence.postMessage('request_location');
            }
        }

        // 刷新当前位置
        function refreshCurrentLocation() {
            showLocationMessage('正在刷新位置...');
            // 通知Flutter端重新获取位置
            FlutterGeofence.postMessage('request_location');
        }

        // 显示位置消息提示
        function showLocationMessage(message) {
            var messageDiv = document.createElement('div');
            messageDiv.innerHTML = message;
            messageDiv.style.cssText = `
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0,0,0,0.8);
                color: white;
                padding: 10px 20px;
                border-radius: 6px;
                font-size: 14px;
                z-index: 2000;
                pointer-events: none;
            `;
            
            document.getElementById('map').appendChild(messageDiv);
            
            // 3秒后自动移除
            setTimeout(function() {
                if (messageDiv.parentNode) {
                    messageDiv.parentNode.removeChild(messageDiv);
                }
            }, 3000);
        }

        function drawGeofences(geofences) {
            geofences.forEach(function(fence) {
                if (fence.type === 'circle') {
                    drawCircleGeofence(fence);
                } else if (fence.type === 'polygon') {
                    drawPolygonGeofence(fence);
                }
            });
        }

        function drawCircleGeofence(fence) {
            // 验证围栏中心坐标
            var validCoords = validateCoordinates(fence.center.longitude, fence.center.latitude);
            var centerLng = validCoords[0];
            var centerLat = validCoords[1];
            
            var circle = new AMap.Circle({
                center: [centerLng, centerLat],
                radius: fence.radius,
                fillColor: '#ff4444',
                fillOpacity: 0.2,
                strokeColor: '#ff4444',
                strokeWeight: 2,
                strokeOpacity: 0.8,
                map: map
            });
            
            // 添加标签
            var marker = new AMap.Marker({
                position: [centerLng, centerLat],
                content: '<div style="background: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; border: 1px solid #ff4444;">' + fence.name + '</div>',
                offset: new AMap.Pixel(-50, -30),
                map: map
            });
            
            geofenceOverlays[fence.id] = { circle: circle, marker: marker };
        }

        function drawPolygonGeofence(fence) {
            var path = fence.vertices.map(function(vertex) {
                // 验证每个顶点的坐标
                var validCoords = validateCoordinates(vertex.longitude, vertex.latitude);
                return [validCoords[0], validCoords[1]];
            });
            
            var polygon = new AMap.Polygon({
                path: path,
                fillColor: '#4444ff',
                fillOpacity: 0.2,
                strokeColor: '#4444ff',
                strokeWeight: 2,
                strokeOpacity: 0.8,
                map: map
            });
            
            // 计算中心点
            var center = calculatePolygonCenter(path);
            var marker = new AMap.Marker({
                position: center,
                content: '<div style="background: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; border: 1px solid #4444ff;">' + fence.name + '</div>',
                offset: new AMap.Pixel(-50, -30),
                map: map
            });
            
            geofenceOverlays[fence.id] = { polygon: polygon, marker: marker };
        }

        function calculatePolygonCenter(path) {
            var sumLng = 0, sumLat = 0;
            path.forEach(function(point) {
                sumLng += point[0];
                sumLat += point[1];
            });
            return [sumLng / path.length, sumLat / path.length];
        }

        // 添加当前位置标记
        function addCurrentLocationMarker(lng, lat) {
            // 验证坐标
            var validCoords = validateCoordinates(lng, lat);
            lng = validCoords[0];
            lat = validCoords[1];
            
            // 如果已存在标记，先移除
            if (currentLocationMarker) {
                currentLocationMarker.setMap(null);
            }
            
            // 创建新的标记
            currentLocationMarker = new AMap.Marker({
                position: [lng, lat],
                icon: new AMap.Icon({
                    size: new AMap.Size(20, 20),
                    imageSize: new AMap.Size(20, 20),
                    image: 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(`
                        <svg width="20" height="20" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="10" cy="10" r="8" fill="#44ff44" fill-opacity="0.6" stroke="#44ff44" stroke-width="2"/>
                            <circle cx="10" cy="10" r="3" fill="#44ff44"/>
                        </svg>
                    `)
                }),
                offset: new AMap.Pixel(-10, -10),
                zIndex: 200,
                map: map
            });

            // 添加脉冲动画效果
            var pulseMarker = new AMap.Marker({
                position: [lng, lat],
                icon: new AMap.Icon({
                    size: new AMap.Size(40, 40),
                    imageSize: new AMap.Size(40, 40),
                    image: 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(`
                        <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="20" cy="20" r="18" fill="#44ff44" fill-opacity="0.2">
                                <animate attributeName="r" from="8" to="18" dur="1.5s" begin="0s" repeatCount="indefinite"/>
                                <animate attributeName="fill-opacity" from="0.3" to="0" dur="1.5s" begin="0s" repeatCount="indefinite"/>
                            </circle>
                        </svg>
                    `)
                }),
                offset: new AMap.Pixel(-20, -20),
                zIndex: 199,
                map: map
            });

            // 保存脉冲标记的引用
            currentLocationMarker.pulseMarker = pulseMarker;
        }

        // 更新当前位置
        function updateCurrentLocation(lng, lat) {
            // 验证坐标
            var validCoords = validateCoordinates(lng, lat);
            lng = validCoords[0];
            lat = validCoords[1];
            
            currentLocation = [lng, lat];
            console.log('Updated current location to:', lng, lat);
            
            // 更新标记位置
            if (currentLocationMarker) {
                currentLocationMarker.setPosition([lng, lat]);
                if (currentLocationMarker.pulseMarker) {
                    currentLocationMarker.pulseMarker.setPosition([lng, lat]);
                }
            } else {
                // 如果标记不存在，创建新标记
                addCurrentLocationMarker(lng, lat);
            }

            // 可选：让地图轻微跟随位置移动（如果距离较远）
            try {
                var currentCenter = map.getCenter();
                var distance = AMap.GeometryUtil.distance(
                    [currentCenter.lng, currentCenter.lat], 
                    [lng, lat]
                );
                
                // 如果距离超过100米，重新居中地图
                if (distance > 100) {
                    map.panTo([lng, lat]);
                }
            } catch (error) {
                console.error('Error calculating distance or panning map:', error);
            }
        }

        function highlightGeofence(geofenceId) {
            // 重置所有围栏样式
            Object.keys(geofenceOverlays).forEach(function(id) {
                var overlay = geofenceOverlays[id];
                if (overlay.circle) {
                    overlay.circle.setOptions({
                        fillColor: '#ff4444',
                        strokeColor: '#ff4444'
                    });
                } else if (overlay.polygon) {
                    overlay.polygon.setOptions({
                        fillColor: '#4444ff',
                        strokeColor: '#4444ff'
                    });
                }
            });
            
            // 高亮触发的围栏
            var overlay = geofenceOverlays[geofenceId];
            if (overlay) {
                if (overlay.circle) {
                    overlay.circle.setOptions({
                        fillColor: '#ffff44',
                        strokeColor: '#ffaa00'
                    });
                } else if (overlay.polygon) {
                    overlay.polygon.setOptions({
                        fillColor: '#ffff44',
                        strokeColor: '#ffaa00'
                    });
                }
                
                // 延迟恢复正常颜色
                setTimeout(function() {
                    if (overlay.circle) {
                        overlay.circle.setOptions({
                            fillColor: '#ff4444',
                            strokeColor: '#ff4444'
                        });
                    } else if (overlay.polygon) {
                        overlay.polygon.setOptions({
                            fillColor: '#4444ff',
                            strokeColor: '#4444ff'
                        });
                    }
                }, 2000);
            }
        }

        // 清空所有围栏
        function clearAllGeofences() {
            console.log('clearAllGeofences called');
            try {
                // 清除地图上的所有围栏覆盖物
                Object.keys(geofenceOverlays).forEach(function(id) {
                    var overlay = geofenceOverlays[id];
                    if (overlay.circle) {
                        overlay.circle.setMap(null);
                    }
                    if (overlay.polygon) {
                        overlay.polygon.setMap(null);
                    }
                    if (overlay.marker) {
                        overlay.marker.setMap(null);
                    }
                });
                
                // 清空覆盖物对象
                geofenceOverlays = {};
                
                console.log('All geofences cleared from map');
                FlutterGeofence.postMessage('所有围栏已从地图清除');
            } catch (error) {
                console.error('Error clearing geofences:', error);
                FlutterGeofence.postMessage('清除围栏时出错: ' + error.message);
            }
        }

        // 重新绘制所有围栏
        function redrawGeofences(geofences) {
            console.log('redrawGeofences called with', geofences.length, 'geofences');
            try {
                // 先清空现有围栏
                clearAllGeofences();
                
                // 重新绘制围栏
                if (geofences && geofences.length > 0) {
                    drawGeofences(geofences);
                    console.log('Redrawn', geofences.length, 'geofences');
                    FlutterGeofence.postMessage('已重新绘制 ' + geofences.length + ' 个围栏');
                } else {
                    console.log('No geofences to draw');
                    FlutterGeofence.postMessage('无围栏需要绘制');
                }
            } catch (error) {
                console.error('Error redrawing geofences:', error);
                FlutterGeofence.postMessage('重新绘制围栏时出错: ' + error.message);
            }
        }

        // 添加单个围栏
        function addSingleGeofence(geofence) {
            console.log('addSingleGeofence called with:', geofence);
            try {
                if (geofence.type === 'circle') {
                    drawCircleGeofence(geofence);
                } else if (geofence.type === 'polygon') {
                    drawPolygonGeofence(geofence);
                }
                console.log('Added geofence:', geofence.name);
                FlutterGeofence.postMessage('已添加围栏: ' + geofence.name);
            } catch (error) {
                console.error('Error adding geofence:', error);
                FlutterGeofence.postMessage('添加围栏时出错: ' + error.message);
            }
        }
    ''';
  }
} 