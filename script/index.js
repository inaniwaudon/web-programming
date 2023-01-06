window.onload = () => {
  const mapInDetail = document.getElementById("map-in-detail");
  const map = document.getElementById("map");
  const yourPlace = document.getElementById("your-place");
  const inputPlace = document.getElementById("input-place");
  const placeCandidate = document.getElementById("place-candidate");
  const latitudeInput = document.getElementById("latitude-input");
  const longitudeInput = document.getElementById("longitude-input");

  const successÇallback = (coords) => {
    let message;
    if (coords.latitude === undefined || coords.longitude === undefined) {
      message = "現在地の取得に失敗しました。";
    }
    else {
      message = `現在地：緯度 ${coords.latitude}、経度 ${coords.latitude}`;
    }
    yourPlace.innerHTML = message;
  };

  const errorCallback = () => {
    yourPlace.innerHTML = "位置情報の取得に失敗しました。ブラウザの設定から位置情報の取得を有効にしてください。";
  };

  navigator.geolocation.getCurrentPosition(successÇallback, errorCallback);

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
  const setCoordinates = () => {
    latitudeInput.value = leafletMap.getCenter().lat;
    longitudeInput.value = leafletMap.getCenter().lng;
  }

  const leafletMap = L.map("map", {
    center: [35.66572, 139.73100],
    zoom: 17,
  });
  const tileLayer = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>",
  });
  tileLayer.addTo(leafletMap);

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
    setCoordinates();
  })
  setCoordinates();

  // display map
  mapInDetail.addEventListener("change", (e) => {
    if (e.target.checked) {
      map.classList.remove("disabled");
    } else {
      map.classList.add("disabled");
    }
  });
};
