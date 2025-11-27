const API_BASE_URL = "https://e0t7dcfjd8.execute-api.us-west-1.amazonaws.com";

async function loadCars() {
  const res = await fetch(`${API_BASE_URL}/cars`);
  const cars = await res.json();
  displayCars(cars);
}

const state = {
  cars: [],
  filtered: [],
};

const query = {
  search: "",
  brand: "all",
  price: "all",
  body: "all",
};

const toastContainer = document.getElementById("toastContainer");

const showToast = (message) => {
  if (!toastContainer) return;
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = message;
  toastContainer.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
};

const formatPrice = (value) =>
  new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  }).format(value || 0);

const fetchJSON = async (path) => {
  const response = await fetch(`${API_BASE_URL}${path}`);
  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || "Request failed");
  }
  return response.json();
};

const getBodyStyle = (car) => {
  const description = `${car.description || ""}`.toLowerCase();
  if (description.includes("suv")) return "suv";
  if (description.includes("truck")) return "truck";
  if (description.includes("convertible")) return "convertible";
  if (description.includes("coupe")) return "coupe";
  return "sedan";
};

const applyFilters = () => {
  state.filtered = state.cars.filter((car) => {
    const haystack = `${car.brand} ${car.model} ${car.description || ""}`.toLowerCase();
    const matchesSearch = haystack.includes(query.search.toLowerCase());

    const matchesBrand = query.brand === "all" || car.brand === query.brand;

    const matchesPrice =
      query.price === "all" || Number(car.price) <= Number(query.price);

    const matchesBody =
      query.body === "all" || getBodyStyle(car) === query.body;

    return matchesSearch && matchesBrand && matchesPrice && matchesBody;
  });

  renderInventory();
};

const updateBrandOptions = () => {
  const select = document.getElementById("brandFilter");
  if (!select) return;
  const uniqueBrands = [...new Set(state.cars.map((car) => car.brand))].sort();
  uniqueBrands.forEach((brand) => {
    const option = document.createElement("option");
    option.value = brand;
    option.textContent = brand;
    select.appendChild(option);
  });
};

const renderInventory = () => {
  const grid = document.getElementById("inventoryGrid");
  const resultCount = document.getElementById("resultCount");
  const noResults = document.getElementById("noResults");
  if (!grid) return;

  grid.innerHTML = "";
  resultCount.textContent = `${state.filtered.length} vehicle${
    state.filtered.length === 1 ? "" : "s"
  }`;

  if (!state.filtered.length) {
    noResults?.classList.remove("hidden");
    return;
  }
  noResults?.classList.add("hidden");

  state.filtered.forEach((car) => {
    const card = document.createElement("article");
    card.className = "vehicle-card";
    card.innerHTML = `
      <img src="${car.imageUrl || "../assets/cars/hero.jpg"}" alt="${car.brand} ${
      car.model
    }" />
      <div class="vehicle-body">
        <h4>${car.brand} ${car.model}</h4>
        <div class="vehicle-meta">
          <span>${car.year}</span>
          <span>${formatPrice(car.price)}</span>
        </div>
        <p>${car.description || "Discover more in person."}</p>
        <div class="vehicle-tags">
          <span>${getBodyStyle(car)}</span>
          <span>${Number(car.mileage || 0).toLocaleString()} mi</span>
        </div>
        <button data-car="${car.carId}">Reserve viewing</button>
      </div>
    `;
    grid.appendChild(card);
  });
};

const initFilters = () => {
  document.getElementById("searchInput")?.addEventListener("input", (event) => {
    query.search = event.target.value;
    applyFilters();
  });

  document.getElementById("searchBtn")?.addEventListener("click", () => {
    applyFilters();
  });

  document.getElementById("brandFilter")?.addEventListener("change", (event) => {
    query.brand = event.target.value;
    applyFilters();
  });

  document.getElementById("priceFilter")?.addEventListener("change", (event) => {
    query.price = event.target.value;
    applyFilters();
  });

  document.getElementById("bodyFilter")?.addEventListener("change", (event) => {
    query.body = event.target.value;
    applyFilters();
  });

  document.getElementById("clearFilters")?.addEventListener("click", () => {
    query.search = "";
    query.brand = "all";
    query.price = "all";
    query.body = "all";
    document.getElementById("searchInput").value = "";
    document.getElementById("brandFilter").value = "all";
    document.getElementById("priceFilter").value = "all";
    document.getElementById("bodyFilter").value = "all";
    applyFilters();
  });
};

const initForms = () => {
  const testDriveForm = document.getElementById("testDriveForm");
  const contactForm = document.getElementById("contactForm");

  testDriveForm?.addEventListener("submit", (event) => {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(testDriveForm).entries());
    console.log("Test drive request", data);
    showToast("Thanks! Our concierge will confirm shortly.");
    testDriveForm.reset();
  });

  contactForm?.addEventListener("submit", (event) => {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(contactForm).entries());
    console.log("Contact request", data);
    showToast("Message received! Expect a reply within 24 hours.");
    contactForm.reset();
  });
};

const initReserveButtons = () => {
  document
    .getElementById("inventoryGrid")
    ?.addEventListener("click", (event) => {
      const button = event.target.closest("button[data-car]");
      if (!button) return;
      const car = state.cars.find((item) => item.carId === button.dataset.car);
      if (!car) return;
      showToast(`Reserved ${car.brand} ${car.model}! We'll reach out shortly.`);
    });
};

const bootstrap = async () => {
  document.getElementById("copyrightYear").textContent =
    new Date().getFullYear();
  try {
    state.cars = await fetchJSON("/cars");
    state.filtered = [...state.cars];
    updateBrandOptions();
    renderInventory();
  } catch (error) {
    console.error(error);
    showToast("Unable to load inventory right now.");
  }
};

initFilters();
initForms();
initReserveButtons();
bootstrap();


