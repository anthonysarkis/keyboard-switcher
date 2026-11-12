import Compression
import Foundation

enum IndexedPNG {
    private static let signature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
    private static let zlibHeader: [UInt8] = [0x78, 0x9C]
    private static let headerTail: [UInt8] = [8, 3, 0, 0, 0]
    private static let noFilter: UInt8 = 0
    private static let adlerModulus: UInt32 = 65521
    private static let crcPolynomial: UInt32 = 0xEDB8_8320
    private static let crcTable: [UInt32] = (0..<256).map { tableIndex in
        var crc = UInt32(tableIndex)
        for _ in 0..<8 {
            crc = crc & 1 == 1 ? crcPolynomial ^ (crc >> 1) : crc >> 1
        }
        return crc
    }

    static func data(width: Int, height: Int, pixelIndices: [UInt8], palette: [PaletteColor]) -> Data? {
        guard pixelIndices.count == width * height, palette.count <= 256 else { return nil }
        var rows: [UInt8] = []
        rows.reserveCapacity((width + 1) * height)
        for row in 0..<height {
            let rowStart = row * width
            rows.append(noFilter)
            rows += pixelIndices[rowStart..<(rowStart + width)]
        }
        guard let compressedRows = deflated(rows) else { return nil }
        let checksum = adler32(of: rows)
        let checksumBytes = bigEndianBytes(of: checksum)
        let zlibStream = zlibHeader + compressedRows + checksumBytes
        let widthValue = UInt32(width)
        let heightValue = UInt32(height)
        let widthBytes = bigEndianBytes(of: widthValue)
        let heightBytes = bigEndianBytes(of: heightValue)
        let header = widthBytes + heightBytes + headerTail
        let colors = palette.flatMap { color in [color.red, color.green, color.blue] }
        let alphas = palette.map(\.alpha)
        let headerChunk = chunk(named: "IHDR", holding: header)
        let paletteChunk = chunk(named: "PLTE", holding: colors)
        let transparencyChunk = chunk(named: "tRNS", holding: alphas)
        let dataChunk = chunk(named: "IDAT", holding: zlibStream)
        let endChunk = chunk(named: "IEND", holding: [])
        let file = signature + headerChunk + paletteChunk + transparencyChunk + dataChunk + endChunk
        return Data(file)
    }

    private static func deflated(_ bytes: [UInt8]) -> [UInt8]? {
        let capacity = bytes.count + 1024
        var output = [UInt8](repeating: 0, count: capacity)
        let writtenCount = compression_encode_buffer(&output, capacity, bytes, bytes.count, nil, COMPRESSION_ZLIB)
        guard writtenCount > 0 else { return nil }
        return Array(output[0..<writtenCount])
    }

    private static func chunk(named name: String, holding content: [UInt8]) -> [UInt8] {
        let length = UInt32(content.count)
        let lengthBytes = bigEndianBytes(of: length)
        let typedContent = Array(name.utf8) + content
        let checksum = crc32(of: typedContent)
        let checksumBytes = bigEndianBytes(of: checksum)
        return lengthBytes + typedContent + checksumBytes
    }

    private static func crc32(of bytes: [UInt8]) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in bytes {
            let byteValue = UInt32(byte)
            let tableIndex = Int((crc ^ byteValue) & 0xFF)
            crc = crcTable[tableIndex] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }

    private static func adler32(of bytes: [UInt8]) -> UInt32 {
        var first: UInt32 = 1
        var second: UInt32 = 0
        for byte in bytes {
            first = (first + UInt32(byte)) % adlerModulus
            second = (second + first) % adlerModulus
        }
        return second << 16 | first
    }

    private static func bigEndianBytes(of value: UInt32) -> [UInt8] {
        [UInt8(value >> 24), UInt8(value >> 16 & 0xFF), UInt8(value >> 8 & 0xFF), UInt8(value & 0xFF)]
    }
}
