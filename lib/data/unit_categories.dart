import 'package:flutter/material.dart';

import '../models/unit.dart';

/// Every conversion factor below is exact (or the accepted SI value) so that
/// results match published conversion tables.
final List<UnitCategory> kUnitCategories = <UnitCategory>[
  _length,
  _weight,
  _area,
  _volume,
  _temperature,
  _speed,
  _time,
  _data,
  _pressure,
  _energy,
  _power,
  _angle,
  _frequency,
  _force,
  _fuelEconomy,
];

UnitCategory? categoryById(String id) {
  for (final category in kUnitCategories) {
    if (category.id == id) return category;
  }
  return null;
}

// ---------------------------------------------------------------- length

final _length = UnitCategory(
  id: 'length',
  name: 'Length',
  icon: Icons.straighten,
  keywords: const ['distance', 'metre', 'meter', 'feet', 'inch', 'km', 'mile'],
  defaultFromId: 'm',
  defaultToId: 'ft',
  units: <Unit>[
    Unit.scaled('nm', 'Nanometre', 'nm', 1e-9),
    Unit.scaled('um', 'Micrometre', 'µm', 1e-6),
    Unit.scaled('mm', 'Millimetre', 'mm', 0.001),
    Unit.scaled('cm', 'Centimetre', 'cm', 0.01),
    Unit.scaled('m', 'Metre', 'm', 1),
    Unit.scaled('km', 'Kilometre', 'km', 1000),
    Unit.scaled('in', 'Inch', 'in', 0.0254),
    Unit.scaled('ft', 'Foot', 'ft', 0.3048),
    Unit.scaled('yd', 'Yard', 'yd', 0.9144),
    Unit.scaled('mi', 'Mile', 'mi', 1609.344),
    Unit.scaled('nmi', 'Nautical mile', 'nmi', 1852),
    Unit.scaled('furlong', 'Furlong', 'fur', 201.168),
    Unit.scaled('ly', 'Light year', 'ly', 9.4607304725808e15),
  ],
);

// ---------------------------------------------------------------- weight

final _weight = UnitCategory(
  id: 'weight',
  name: 'Weight',
  icon: Icons.monitor_weight_outlined,
  keywords: const ['mass', 'kg', 'gram', 'pound', 'lbs', 'ounce', 'tonne'],
  defaultFromId: 'kg',
  defaultToId: 'lb',
  units: <Unit>[
    Unit.scaled('ug', 'Microgram', 'µg', 1e-9),
    Unit.scaled('mg', 'Milligram', 'mg', 1e-6),
    Unit.scaled('g', 'Gram', 'g', 0.001),
    Unit.scaled('kg', 'Kilogram', 'kg', 1),
    Unit.scaled('q', 'Quintal', 'q', 100),
    Unit.scaled('t', 'Metric tonne', 't', 1000),
    Unit.scaled('ct', 'Carat', 'ct', 0.0002),
    Unit.scaled('tola', 'Tola', 'tola', 0.0116638),
    Unit.scaled('oz', 'Ounce', 'oz', 0.028349523125),
    Unit.scaled('lb', 'Pound', 'lb', 0.45359237),
    Unit.scaled('st', 'Stone', 'st', 6.35029318),
    Unit.scaled('ton_us', 'Short ton (US)', 'ton', 907.18474),
    Unit.scaled('ton_uk', 'Long ton (UK)', 'ton', 1016.0469088),
  ],
);

// ------------------------------------------------------------------ area

final _area = UnitCategory(
  id: 'area',
  name: 'Area',
  icon: Icons.square_foot,
  keywords: const ['acre', 'hectare', 'sq ft', 'square', 'plot', 'land'],
  defaultFromId: 'sqm',
  defaultToId: 'sqft',
  units: <Unit>[
    Unit.scaled('sqmm', 'Square millimetre', 'mm²', 1e-6),
    Unit.scaled('sqcm', 'Square centimetre', 'cm²', 1e-4),
    Unit.scaled('sqm', 'Square metre', 'm²', 1),
    Unit.scaled('are', 'Are', 'a', 100),
    Unit.scaled('ha', 'Hectare', 'ha', 10000),
    Unit.scaled('sqkm', 'Square kilometre', 'km²', 1e6),
    Unit.scaled('sqin', 'Square inch', 'in²', 0.00064516),
    Unit.scaled('sqft', 'Square foot', 'ft²', 0.09290304),
    Unit.scaled('sqyd', 'Square yard', 'yd²', 0.83612736),
    Unit.scaled('cent', 'Cent', 'cent', 40.468564224),
    Unit.scaled('guntha', 'Guntha', 'guntha', 101.17141056),
    Unit.scaled('acre', 'Acre', 'ac', 4046.8564224),
    Unit.scaled('sqmi', 'Square mile', 'mi²', 2589988.110336),
  ],
);

// ---------------------------------------------------------------- volume

final _volume = UnitCategory(
  id: 'volume',
  name: 'Volume',
  icon: Icons.local_drink_outlined,
  keywords: const ['litre', 'liter', 'gallon', 'cup', 'ml', 'capacity'],
  defaultFromId: 'l',
  defaultToId: 'gal_us',
  units: <Unit>[
    Unit.scaled('ml', 'Millilitre', 'ml', 0.001),
    Unit.scaled('cc', 'Cubic centimetre', 'cm³', 0.001),
    Unit.scaled('l', 'Litre', 'L', 1),
    Unit.scaled('cum', 'Cubic metre', 'm³', 1000),
    Unit.scaled('cuin', 'Cubic inch', 'in³', 0.016387064),
    Unit.scaled('cuft', 'Cubic foot', 'ft³', 28.316846592),
    Unit.scaled('tsp', 'Teaspoon (US)', 'tsp', 0.00492892159375),
    Unit.scaled('tbsp', 'Tablespoon (US)', 'tbsp', 0.01478676478125),
    Unit.scaled('floz_us', 'Fluid ounce (US)', 'fl oz', 0.0295735295625),
    Unit.scaled('cup', 'Cup (US)', 'cup', 0.2365882365),
    Unit.scaled('pt_us', 'Pint (US)', 'pt', 0.473176473),
    Unit.scaled('qt_us', 'Quart (US)', 'qt', 0.946352946),
    Unit.scaled('gal_us', 'Gallon (US)', 'gal', 3.785411784),
    Unit.scaled('floz_uk', 'Fluid ounce (UK)', 'fl oz', 0.0284130625),
    Unit.scaled('pt_uk', 'Pint (UK)', 'pt', 0.56826125),
    Unit.scaled('gal_uk', 'Gallon (UK)', 'gal', 4.54609),
    Unit.scaled('bbl', 'Barrel (oil)', 'bbl', 158.987294928),
  ],
);

// ----------------------------------------------------------- temperature

final _temperature = UnitCategory(
  id: 'temperature',
  name: 'Temperature',
  icon: Icons.thermostat,
  keywords: const ['celsius', 'fahrenheit', 'kelvin', 'degree', 'heat'],
  defaultFromId: 'c',
  defaultToId: 'f',
  note: 'Temperature scales have different zero points, so they are converted '
      'with formulas rather than a single multiplier.',
  units: <Unit>[
    Unit(
      id: 'c',
      name: 'Celsius',
      symbol: '°C',
      toBase: (v) => v,
      fromBase: (v) => v,
    ),
    Unit(
      id: 'f',
      name: 'Fahrenheit',
      symbol: '°F',
      toBase: (v) => (v - 32) * 5 / 9,
      fromBase: (v) => v * 9 / 5 + 32,
    ),
    Unit(
      id: 'k',
      name: 'Kelvin',
      symbol: 'K',
      toBase: (v) => v - 273.15,
      fromBase: (v) => v + 273.15,
    ),
    Unit(
      id: 'r',
      name: 'Rankine',
      symbol: '°R',
      toBase: (v) => (v - 491.67) * 5 / 9,
      fromBase: (v) => (v + 273.15) * 9 / 5,
    ),
    Unit(
      id: 're',
      name: 'Réaumur',
      symbol: '°Ré',
      toBase: (v) => v * 5 / 4,
      fromBase: (v) => v * 4 / 5,
    ),
  ],
);

// ----------------------------------------------------------------- speed

final _speed = UnitCategory(
  id: 'speed',
  name: 'Speed',
  icon: Icons.speed,
  keywords: const ['velocity', 'kmph', 'mph', 'knot', 'mach'],
  defaultFromId: 'kmh',
  defaultToId: 'mph',
  units: <Unit>[
    Unit.scaled('mps', 'Metre / second', 'm/s', 1),
    Unit.scaled('kmh', 'Kilometre / hour', 'km/h', 1 / 3.6),
    Unit.scaled('mph', 'Mile / hour', 'mph', 0.44704),
    Unit.scaled('fps', 'Foot / second', 'ft/s', 0.3048),
    Unit.scaled('knot', 'Knot', 'kn', 1852 / 3600),
    Unit.scaled('kms', 'Kilometre / second', 'km/s', 1000),
    Unit.scaled('mach', 'Mach (sea level)', 'M', 340.29),
  ],
);

// ------------------------------------------------------------------ time

final _time = UnitCategory(
  id: 'time',
  name: 'Time',
  icon: Icons.schedule,
  keywords: const ['duration', 'hour', 'minute', 'second', 'week', 'year'],
  defaultFromId: 'h',
  defaultToId: 'min',
  note: 'An average month is 30.44 days and an average year is 365.2425 days.',
  units: <Unit>[
    Unit.scaled('ns', 'Nanosecond', 'ns', 1e-9),
    Unit.scaled('us', 'Microsecond', 'µs', 1e-6),
    Unit.scaled('ms', 'Millisecond', 'ms', 0.001),
    Unit.scaled('s', 'Second', 's', 1),
    Unit.scaled('min', 'Minute', 'min', 60),
    Unit.scaled('h', 'Hour', 'h', 3600),
    Unit.scaled('d', 'Day', 'd', 86400),
    Unit.scaled('wk', 'Week', 'wk', 604800),
    Unit.scaled('fortnight', 'Fortnight', 'fn', 1209600),
    Unit.scaled('mo30', 'Month (30 days)', 'mo', 2592000),
    Unit.scaled('mo', 'Month (average)', 'mo', 2629746),
    Unit.scaled('yr365', 'Year (365 days)', 'yr', 31536000),
    Unit.scaled('yr', 'Year (average)', 'yr', 31556952),
    Unit.scaled('decade', 'Decade', 'dec', 315569520),
    Unit.scaled('century', 'Century', 'c', 3155695200),
  ],
);

// ------------------------------------------------------------------ data

final _data = UnitCategory(
  id: 'data',
  name: 'Data',
  icon: Icons.sd_storage_outlined,
  keywords: const ['storage', 'byte', 'mb', 'gb', 'memory', 'file size'],
  defaultFromId: 'mb',
  defaultToId: 'gb',
  note: 'Decimal units (KB, MB, GB) step by 1000. Binary units (KiB, MiB, GiB) '
      'step by 1024 — this is what most operating systems report.',
  units: <Unit>[
    Unit.scaled('bit', 'Bit', 'b', 0.125),
    Unit.scaled('byte', 'Byte', 'B', 1),
    Unit.scaled('kbit', 'Kilobit', 'kb', 125),
    Unit.scaled('kb', 'Kilobyte', 'KB', 1e3),
    Unit.scaled('kib', 'Kibibyte', 'KiB', 1024),
    Unit.scaled('mbit', 'Megabit', 'Mb', 125000),
    Unit.scaled('mb', 'Megabyte', 'MB', 1e6),
    Unit.scaled('mib', 'Mebibyte', 'MiB', 1048576),
    Unit.scaled('gbit', 'Gigabit', 'Gb', 1.25e8),
    Unit.scaled('gb', 'Gigabyte', 'GB', 1e9),
    Unit.scaled('gib', 'Gibibyte', 'GiB', 1073741824),
    Unit.scaled('tb', 'Terabyte', 'TB', 1e12),
    Unit.scaled('tib', 'Tebibyte', 'TiB', 1099511627776),
    Unit.scaled('pb', 'Petabyte', 'PB', 1e15),
  ],
);

// -------------------------------------------------------------- pressure

final _pressure = UnitCategory(
  id: 'pressure',
  name: 'Pressure',
  icon: Icons.compress,
  keywords: const ['psi', 'bar', 'pascal', 'tyre', 'tire', 'atm'],
  defaultFromId: 'bar',
  defaultToId: 'psi',
  units: <Unit>[
    Unit.scaled('pa', 'Pascal', 'Pa', 1),
    Unit.scaled('hpa', 'Hectopascal', 'hPa', 100),
    Unit.scaled('kpa', 'Kilopascal', 'kPa', 1000),
    Unit.scaled('mpa', 'Megapascal', 'MPa', 1e6),
    Unit.scaled('mbar', 'Millibar', 'mbar', 100),
    Unit.scaled('bar', 'Bar', 'bar', 1e5),
    Unit.scaled('atm', 'Atmosphere', 'atm', 101325),
    Unit.scaled('mmhg', 'Millimetre of mercury', 'mmHg', 133.322387415),
    Unit.scaled('inhg', 'Inch of mercury', 'inHg', 3386.388640341),
    Unit.scaled('psi', 'Pound / square inch', 'psi', 6894.757293168361),
    Unit.scaled('kgfcm2', 'Kilogram-force / cm²', 'kgf/cm²', 98066.5),
  ],
);

// ---------------------------------------------------------------- energy

final _energy = UnitCategory(
  id: 'energy',
  name: 'Energy',
  icon: Icons.local_fire_department_outlined,
  keywords: const ['joule', 'calorie', 'kwh', 'btu', 'work', 'heat'],
  defaultFromId: 'kcal',
  defaultToId: 'kj',
  units: <Unit>[
    Unit.scaled('j', 'Joule', 'J', 1),
    Unit.scaled('kj', 'Kilojoule', 'kJ', 1000),
    Unit.scaled('mj', 'Megajoule', 'MJ', 1e6),
    Unit.scaled('cal', 'Calorie', 'cal', 4.184),
    Unit.scaled('kcal', 'Kilocalorie (food cal)', 'kcal', 4184),
    Unit.scaled('wh', 'Watt-hour', 'Wh', 3600),
    Unit.scaled('kwh', 'Kilowatt-hour', 'kWh', 3.6e6),
    Unit.scaled('btu', 'British thermal unit', 'BTU', 1055.05585262),
    Unit.scaled('therm', 'Therm', 'thm', 105505585.262),
    Unit.scaled('ftlb', 'Foot-pound', 'ft·lb', 1.3558179483314004),
    Unit.scaled('erg', 'Erg', 'erg', 1e-7),
    Unit.scaled('ev', 'Electronvolt', 'eV', 1.602176634e-19),
  ],
);

// ----------------------------------------------------------------- power

final _power = UnitCategory(
  id: 'power',
  name: 'Power',
  icon: Icons.bolt,
  keywords: const ['watt', 'horsepower', 'hp', 'kw', 'electricity'],
  defaultFromId: 'kw',
  defaultToId: 'hp',
  units: <Unit>[
    Unit.scaled('mw_milli', 'Milliwatt', 'mW', 0.001),
    Unit.scaled('w', 'Watt', 'W', 1),
    Unit.scaled('kw', 'Kilowatt', 'kW', 1000),
    Unit.scaled('mw', 'Megawatt', 'MW', 1e6),
    Unit.scaled('gw', 'Gigawatt', 'GW', 1e9),
    Unit.scaled('hp', 'Horsepower (mechanical)', 'hp', 745.6998715822702),
    Unit.scaled('ps', 'Horsepower (metric)', 'PS', 735.49875),
    Unit.scaled('btuh', 'BTU / hour', 'BTU/h', 0.29307107017222),
    Unit.scaled('kcalh', 'Kilocalorie / hour', 'kcal/h', 1.163),
    Unit.scaled('ftlbs', 'Foot-pound / second', 'ft·lb/s', 1.3558179483314004),
    Unit.scaled('tonref', 'Ton of refrigeration', 'TR', 3516.8528420667),
  ],
);

// ----------------------------------------------------------------- angle

final _angle = UnitCategory(
  id: 'angle',
  name: 'Angle',
  icon: Icons.architecture,
  keywords: const ['degree', 'radian', 'gradian', 'rotation'],
  defaultFromId: 'deg',
  defaultToId: 'rad',
  units: <Unit>[
    Unit.scaled('deg', 'Degree', '°', 1),
    Unit.scaled('rad', 'Radian', 'rad', 57.29577951308232),
    Unit.scaled('grad', 'Gradian', 'grad', 0.9),
    Unit.scaled('arcmin', 'Arcminute', "'", 1 / 60),
    Unit.scaled('arcsec', 'Arcsecond', '"', 1 / 3600),
    Unit.scaled('turn', 'Turn', 'turn', 360),
  ],
);

// ------------------------------------------------------------- frequency

final _frequency = UnitCategory(
  id: 'frequency',
  name: 'Frequency',
  icon: Icons.graphic_eq,
  keywords: const ['hertz', 'hz', 'rpm', 'ghz', 'cpu'],
  defaultFromId: 'hz',
  defaultToId: 'khz',
  units: <Unit>[
    Unit.scaled('hz', 'Hertz', 'Hz', 1),
    Unit.scaled('khz', 'Kilohertz', 'kHz', 1e3),
    Unit.scaled('mhz', 'Megahertz', 'MHz', 1e6),
    Unit.scaled('ghz', 'Gigahertz', 'GHz', 1e9),
    Unit.scaled('thz', 'Terahertz', 'THz', 1e12),
    Unit.scaled('rpm', 'Revolution / minute', 'rpm', 1 / 60),
    Unit.scaled('bpm', 'Beat / minute', 'bpm', 1 / 60),
  ],
);

// ----------------------------------------------------------------- force

final _force = UnitCategory(
  id: 'force',
  name: 'Force',
  icon: Icons.fitness_center,
  keywords: const ['newton', 'kgf', 'pound force', 'thrust'],
  defaultFromId: 'n',
  defaultToId: 'kgf',
  units: <Unit>[
    Unit.scaled('n', 'Newton', 'N', 1),
    Unit.scaled('kn', 'Kilonewton', 'kN', 1000),
    Unit.scaled('dyn', 'Dyne', 'dyn', 1e-5),
    Unit.scaled('kgf', 'Kilogram-force', 'kgf', 9.80665),
    Unit.scaled('gf', 'Gram-force', 'gf', 0.00980665),
    Unit.scaled('lbf', 'Pound-force', 'lbf', 4.4482216152605),
    Unit.scaled('ozf', 'Ounce-force', 'ozf', 0.2780138509537812),
    Unit.scaled('pdl', 'Poundal', 'pdl', 0.138254954376),
  ],
);

// ---------------------------------------------------------- fuel economy

/// Base unit: kilometres per litre. `L/100 km` is inversely proportional,
/// which the per-unit conversion functions handle naturally.
final _fuelEconomy = UnitCategory(
  id: 'fuel_economy',
  name: 'Fuel economy',
  icon: Icons.local_gas_station_outlined,
  keywords: const ['mileage', 'mpg', 'kmpl', 'l/100km', 'average'],
  defaultFromId: 'kmpl',
  defaultToId: 'mpg_us',
  note: 'L/100 km is inverse: a lower number means better efficiency.',
  units: <Unit>[
    Unit.scaled('kmpl', 'Kilometre / litre', 'km/L', 1),
    Unit(
      id: 'l100km',
      name: 'Litre / 100 km',
      symbol: 'L/100km',
      toBase: (v) => v == 0 ? double.infinity : 100 / v,
      fromBase: (v) => v == 0 ? double.infinity : 100 / v,
    ),
    Unit.scaled('mpg_us', 'Mile / gallon (US)', 'mpg', 0.4251437074976),
    Unit.scaled('mpg_uk', 'Mile / gallon (UK)', 'mpg', 0.35400618999999997),
    Unit.scaled('mpl', 'Mile / litre', 'mi/L', 1.609344),
  ],
);
