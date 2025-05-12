extension UInt64: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
extension UInt32: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
extension UInt16: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
extension UInt8: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
extension UInt: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
extension Int64: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Int32: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Int16: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Int8: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Int: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension String: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Bool: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Double: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}

extension Float: Intention {
  func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
    return valueMapper.map(self)
  }
}
