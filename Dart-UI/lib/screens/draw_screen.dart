import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

import '../services/content_service.dart';

/// Một điểm vẽ trên canvas.
class DrawPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    required this.isEraser,
  });
}

/// Màn hình Art Studio.
class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<DrawPoint> _points = [];

  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 3.0;
  bool _isEraser = false;

  final GlobalKey _canvasKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();

  final List<Color> _colorPalette = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
  ];

  /// Bắt đầu một nét vẽ.
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points.add(
        DrawPoint(
          offset: details.localPosition,
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          isEraser: _isEraser,
        ),
      );
    });
  }

  /// Ghi nhận điểm vẽ khi người dùng kéo tay.
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(
        DrawPoint(
          offset: details.localPosition,
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          isEraser: _isEraser,
        ),
      );
    });
  }

  /// Kết thúc một nét vẽ.
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(
        DrawPoint(
          offset: Offset.zero,
          color: Colors.transparent,
          strokeWidth: 0,
          isEraser: false,
        ),
      );
    });
  }

  /// Mở bảng chọn màu tùy chỉnh.
  void _pickCustomColor() {
    Color pickedColor = _currentColor;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _currentColor = pickedColor;
                  _isEraser = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Chọn'),
            ),
          ],
        );
      },
    );
  }

  /// Hoàn tác nét vẽ gần nhất.
  void _undo() {
    if (_points.isEmpty) return;

    setState(() {
      while (_points.isNotEmpty &&
          _points.last.offset != Offset.zero &&
          _points.last.color != Colors.transparent) {
        _points.removeLast();
      }

      if (_points.isNotEmpty) {
        _points.removeLast();
      }
    });
  }

  /// Xóa toàn bộ canvas.
  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  /// Xuất nội dung canvas thành ảnh PNG.
  Future<Uint8List?> _exportDrawingPng() async {
    final boundary = _canvasKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Lưu bản vẽ bằng cách xuất PNG, upload ảnh và tạo bản ghi tác phẩm.
  Future<void> _saveDrawing() async {
    if (_points.isEmpty) return;

    final pngBytes = await _exportDrawingPng();

    if (pngBytes == null) return;

    final imageUrl = await ContentService.uploadArtworkImageBytes(
      pngBytes,
      filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    if (imageUrl == null) return;

    await ContentService.createArtwork(
      title: 'Tác phẩm từ Art Studio',
      description: 'Tác phẩm được tạo từ canvas.',
      imageUrl: imageUrl,
      sourceType: 'draw',
      isPublic: true,
    );
  }

  /// Chọn ảnh từ thư viện thiết bị và tạo tác phẩm.
  Future<void> _uploadFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();

    final imageUrl = await ContentService.uploadArtworkImageBytes(
      bytes,
      filename: image.name,
    );

    if (imageUrl == null) return;

    await ContentService.createArtwork(
      title: 'Tác phẩm từ thư viện',
      description: 'Ảnh được chọn từ thư viện thiết bị.',
      imageUrl: imageUrl,
      sourceType: 'upload',
      isPublic: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: RepaintBoundary(
                key: _canvasKey,
                child: CustomPaint(
                  painter: DrawingPainter(points: _points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          _buildToolPanel(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Studio Sáng Tạo',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_library_outlined),
          onPressed: _uploadFromGallery,
        ),
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: _undo,
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearCanvas,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveDrawing,
        ),
      ],
    );
  }

  Widget _buildToolPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildColorPalette(),
          const SizedBox(height: 12),
          _buildToolButtons(),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorPalette.length,
        itemBuilder: (context, index) {
          final color = _colorPalette[index];
          final selected = _currentColor == color && !_isEraser;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentColor = color;
                _isEraser = false;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.grey.shade700, width: 3)
                    : Border.all(color: Colors.black12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolButtons() {
    return Row(
      children: [
        _buildToolButton(
          icon: Icons.brush,
          label: 'Bút vẽ',
          isActive: !_isEraser,
          onTap: () {
            setState(() => _isEraser = false);
          },
        ),
        _buildToolButton(
          icon: Icons.cleaning_services,
          label: 'Tẩy',
          isActive: _isEraser,
          onTap: () {
            setState(() => _isEraser = true);
          },
        ),
        _buildToolButton(
          icon: Icons.color_lens,
          label: 'Màu',
          isActive: false,
          onTap: _pickCustomColor,
        ),
        Expanded(
          child: Column(
            children: [
              Slider(
                value: _currentStrokeWidth,
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() => _currentStrokeWidth = value);
                },
              ),
              Text('Độ dày: ${_currentStrokeWidth.toStringAsFixed(0)}px'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurple.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.deepPurple : Colors.black12,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.deepPurple : Colors.black87),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter vẽ các điểm trên canvas.
class DrawingPainter extends CustomPainter {
  final List<DrawPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, background);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      if (current.offset == Offset.zero ||
          next.offset == Offset.zero ||
          current.color == Colors.transparent ||
          next.color == Colors.transparent) {
        continue;
      }

      final paint = Paint()
        ..color = current.isEraser ? Colors.white : current.color
        ..strokeWidth = current.strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(current.offset, next.offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}