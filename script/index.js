window.onload = () => {
  // dom
  const mapInDetail = document.getElementById("map-in-detail");
  const map = document.getElementById("map");
  const yourPlace = document.getElementById("your-place");
  const inputPlace = document.getElementById("input-place");
  const placeCandidate = document.getElementById("place-candidate");
  const latitudeInput = document.getElementById("latitude-input");
  const longitudeInput = document.getElementById("longitude-input");

  // candidate
  inputPlace.addEventListener("keydown", (e) => {
    if (e.isComposing) {
      return;
    }
    placeCandidate.innerHTML = "";
    const candidates = places.filter(place => place.indexOf(e.target.value) == 0);
    for (const candidate of candidates) {
      const option = document.createElement("option");
      option.value = candidate;
      placeCandidate.appendChild(option);
    }
  });

  // map
  const initialLatitude = 35.66572;
  const initialLongitude = 139.73100;

  const leafletMap = L.map("map", {
    center: [initialLatitude, initialLongitude],
    zoom: 17,
  });
  const tileLayer = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>",
  });
  tileLayer.addTo(leafletMap);

  const setCoordinates = (latitude, longitude) => {
    latitudeInput.value = latitude;
    longitudeInput.value = longitude;leafletMap.getCenter().lng;
  }

  const panTo = (latitude, longitude) => {
    leafletMap.panTo(new L.LatLng(latitude, longitude));
    setCoordinates(latitude, longitude);
  };

  const crossIcon = L.icon({
    iconUrl: "https://maps.gsi.go.jp/image/map/crosshairs.png",
    iconSize: [32, 32], 
    iconAnchor: [16, 16],
  });
  const crossMarker = L.marker(leafletMap.getCenter(), {
    icon: crossIcon,  
    zIndexOffset: 1000, 
    interactive: false 
  }).addTo(leafletMap);
  leafletMap.on("move", () => {
    crossMarker.setLatLng(leafletMap.getCenter());
  });
  leafletMap.on("moveend", () => {
    setCoordinates(leafletMap.getCenter().lat, leafletMap.getCenter().lng);
  })
  panTo(initialLatitude, initialLongitude);

  // switch the display of the map
  mapInDetail.addEventListener("change", (e) => {
    if (e.target.checked) {
      map.classList.remove("disabled");
    } else {
      map.classList.add("disabled");
    }
  });

  // current location
  const successÇallback = (position) => {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;
    if (latitude === undefined || longitude === undefined) {
      yourPlace.innerHTML = "現在地の取得に失敗しました。";
    }
    else {
      yourPlace.innerHTML = `現在地<ul class="current-location-list"><li>緯度 ${latitude}</li><li>経度 ${longitude}</li>`;
      const a = document.createElement("a");
      a.addEventListener("click", () => {
        panTo(latitude, longitude);
      });
      a.innerHTML = "地図の中心を現在地に戻す";
      yourPlace.appendChild(a);
      panTo(latitude, longitude);
    }
  };

  const errorCallback = () => {
    yourPlace.innerHTML = "位置情報の取得に失敗しました。ブラウザの設定から位置情報の取得を有効にしてください。";
  };

  navigator.geolocation.getCurrentPosition(successÇallback, errorCallback);
};
