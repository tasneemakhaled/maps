class Address {
  String? village;
  String? municipality;
  String? county;
  String? iso31662Lvl6;
  String? state;
  String? iso31662Lvl4;
  String? region;
  String? postcode;
  String? country;
  String? countryCode;

  Address({
    this.village,
    this.municipality,
    this.county,
    this.iso31662Lvl6,
    this.state,
    this.iso31662Lvl4,
    this.region,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    village: json['village'] as String?,
    municipality: json['municipality'] as String?,
    county: json['county'] as String?,
    iso31662Lvl6: json['ISO3166-2-lvl6'] as String?,
    state: json['state'] as String?,
    iso31662Lvl4: json['ISO3166-2-lvl4'] as String?,
    region: json['region'] as String?,
    postcode: json['postcode'] as String?,
    country: json['country'] as String?,
    countryCode: json['country_code'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'village': village,
    'municipality': municipality,
    'county': county,
    'ISO3166-2-lvl6': iso31662Lvl6,
    'state': state,
    'ISO3166-2-lvl4': iso31662Lvl4,
    'region': region,
    'postcode': postcode,
    'country': country,
    'country_code': countryCode,
  };
}
