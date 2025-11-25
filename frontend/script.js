// Base API URL – update to match your deployed API Gateway invoke URL.
const API_BASE_URL = "https://e0t7dcfjd8.execute-api.us-west-1.amazonaws.com";

// Cache shared DOM nodes for loaders and toasts.
const toastContainer = document.getElementById("toastContainer");
const loader = document.getElementById("globalLoader");
const loaderMessage = loader?.querySelector("p");

const jsonHeaders = { "Content-Type": "application/json" };

// --- Helper utilities ------------------------------------------------------

const showToast = (message, type = "success", duration = 3500) => {
  if (!toastContainer) return;
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${message}</span><button aria-label="Close">✕</button>`;
  toast.querySelector("button").onclick = () => toast.remove();
  toastContainer.appendChild(toast);
  setTimeout(() => toast.remove(), duration);
};

const setLoading = (state, message = "Loading...") => {
  if (!loader) return;
  loaderMessage.textContent = message;
  loader.classList.toggle("hidden", !state);
};

const handleError = (error) => {
  console.error(error);
  showToast(error.message || "Something went wrong", "error");
};

const request = async (endpoint, options = {}) => {
  const config = { ...options };
  config.headers = {
    ...(options.body ? jsonHeaders : {}),
    ...(options.headers || {}),
  };
  const response = await fetch(`${API_BASE_URL}${endpoint}`, config);
  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || `Request failed: ${response.status}`);
  }
  if (response.status === 204) return null;
  return response.json();
};

// --- API functions ---------------------------------------------------------
const getCars = () => request("/cars");
const getCar = (id) => request(`/cars/${id}`);
const createCar = (data) =>
  request("/cars", { method: "POST", body: JSON.stringify(data) });
const updateCar = (id, data) =>
  request(`/cars/${id}`, { method: "PUT", body: JSON.stringify(data) });
const deleteCar = (id) => request(`/cars/${id}`, { method: "DELETE" });

const uploadImage = async (file) => {
  if (!file) return null;
  const filename = `${Date.now()}-${file.name}`;
  // Ask backend for a presigned URL.
  const { uploadUrl, objectUrl } = await request("/cars/upload", {
    method: "POST",
    body: JSON.stringify({ filename }),
  });
  // Upload directly to S3 using the provided URL.
  const uploadResponse = await fetch(uploadUrl, {
    method: "PUT",
    body: file,
  });
  if (!uploadResponse.ok) {
    throw new Error("Image upload failed");
  }
  return objectUrl;
};

// --- Formatting helpers ----------------------------------------------------
const formatCurrency = (value) =>
  new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  }).format(value || 0);

const formatNumber = (value) =>
  new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 }).format(
    value || 0
  );

const getQueryParam = (key) => {
  const params = new URLSearchParams(window.location.search);
  return params.get(key);
};

// --- Page-specific logic ----------------------------------------------------
const initListPage = () => {
  const grid = document.getElementById("carGrid");
  const emptyState = document.getElementById("emptyState");

  const renderCars = (cars = []) => {
    if (!grid) return;
    grid.innerHTML = "";
    if (!cars.length) {
      emptyState?.classList.remove("hidden");
      return;
    }
    emptyState?.classList.add("hidden");
    cars.forEach((car) => {
      const card = document.createElement("article");
      card.className = "car-card";
      card.innerHTML = `
        <img src="${car.imageUrl || "https://placehold.co/600x400"}" alt="${
        car.brand
      } ${car.model}" />
        <div class="car-card-body">
          <h3>${car.brand} ${car.model}</h3>
          <div class="car-meta">
            <span>${car.year}</span>
            <span>${formatCurrency(car.price)}</span>
          </div>
          <p>${car.description || "No description provided."}</p>
          <div class="car-meta">
            <span>Mileage</span>
            <span>${formatNumber(car.mileage)} mi</span>
          </div>
          <div class="car-actions">
            <a class="btn ghost" href="car-details.html?id=${
              car.carId
            }">View Details</a>
            <a class="btn secondary" href="edit-car.html?id=${
              car.carId
            }">Edit</a>
            <button class="btn danger" data-delete="${car.carId}">Delete</button>
          </div>
        </div>
      `;
      grid.appendChild(card);
    });
  };

  const loadCars = async () => {
    try {
      setLoading(true);
      const cars = await getCars();
      renderCars(cars);
    } catch (error) {
      handleError(error);
    } finally {
      setLoading(false);
    }
  };

  grid?.addEventListener("click", async (event) => {
    const target = event.target;
    if (target.matches("[data-delete]")) {
      const carId = target.getAttribute("data-delete");
      const confirmed = confirm("Delete this car permanently?");
      if (!confirmed) return;
      try {
        setLoading(true, "Deleting car...");
        await deleteCar(carId);
        showToast("Car deleted");
        await loadCars();
      } catch (error) {
        handleError(error);
      } finally {
        setLoading(false);
      }
    }
  });

  document.getElementById("refreshCars")?.addEventListener("click", loadCars);
  document.getElementById("scrollToInventory")?.addEventListener("click", () => {
    document.getElementById("inventorySection")?.scrollIntoView({
      behavior: "smooth",
    });
  });
  loadCars();
};

const initAddCarPage = () => {
  const form = document.getElementById("addCarForm");
  const imageInput = document.getElementById("addImageInput");
  const preview = document.getElementById("addImagePreview");
  let uploadedImageUrl = null;

  const previewImage = (file, container) => {
    if (!container) return;
    container.innerHTML = "";
    if (!file) {
      container.innerHTML = "<p>No image selected.</p>";
      return;
    }
    const img = document.createElement("img");
    img.src = URL.createObjectURL(file);
    img.onload = () => URL.revokeObjectURL(img.src);
    container.appendChild(img);
  };

  imageInput?.addEventListener("change", async (event) => {
    const file = event.target.files?.[0];
    previewImage(file, preview);
    if (!file) {
      uploadedImageUrl = null;
      return;
    }
    try {
      setLoading(true, "Uploading image...");
      uploadedImageUrl = await uploadImage(file);
      showToast("Image uploaded");
    } catch (error) {
      uploadedImageUrl = null;
      handleError(error);
    } finally {
      setLoading(false);
    }
  });

  form?.addEventListener("submit", async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }
    const payload = Object.fromEntries(formData.entries());
    payload.year = Number(payload.year);
    payload.price = Number(payload.price);
    payload.mileage = Number(payload.mileage);
    payload.imageUrl = uploadedImageUrl || null;
    try {
      setLoading(true, "Creating car...");
      await createCar(payload);
      showToast("Car created");
      form.reset();
      previewImage(null, preview);
      uploadedImageUrl = null;
    } catch (error) {
      handleError(error);
    } finally {
      setLoading(false);
    }
  });
};

const initDetailsPage = async () => {
  const carId = getQueryParam("id");
  if (!carId) {
    showToast("Missing car id", "error");
    window.location.href = "index.html";
    return;
  }
  try {
    setLoading(true);
    const car = await getCar(carId);
    document.getElementById("detailsTitle").textContent = `${car.brand} ${car.model}`;
    document.getElementById("detailsDescription").textContent =
      car.description || "No description provided.";
    document.getElementById("detailsBrand").textContent = car.brand;
    document.getElementById("detailsModel").textContent = car.model;
    document.getElementById("detailsYear").textContent = car.year;
    document.getElementById("detailsPrice").textContent = formatCurrency(
      car.price
    );
    document.getElementById("detailsMileage").textContent = `${formatNumber(
      car.mileage
    )} mi`;
    document
      .getElementById("detailsImage")
      .setAttribute(
        "src",
        car.imageUrl || "https://placehold.co/800x600?text=No+Image"
      );

    document
      .getElementById("editCarBtn")
      ?.addEventListener(
        "click",
        () => (window.location.href = `edit-car.html?id=${car.carId}`)
      );
    document.getElementById("deleteCarBtn")?.addEventListener("click", async () => {
      if (!confirm("Delete this car?")) return;
      try {
        setLoading(true, "Deleting car...");
        await deleteCar(car.carId);
        showToast("Car deleted");
        window.location.href = "index.html";
      } catch (error) {
        handleError(error);
      } finally {
        setLoading(false);
      }
    });
  } catch (error) {
    handleError(error);
    window.location.href = "index.html";
  } finally {
    setLoading(false);
  }
};

const initEditPage = async () => {
  const carId = getQueryParam("id");
  if (!carId) {
    showToast("Missing car id", "error");
    window.location.href = "index.html";
    return;
  }
  const form = document.getElementById("editCarForm");
  const imageInput = document.getElementById("editImageInput");
  const preview = document.getElementById("editImagePreview");
  const currentImage = document.getElementById("currentImage");
  let existingImageUrl = null;
  let replacementImageUrl = null;

  const populateForm = (car) => {
    form.brand.value = car.brand;
    form.model.value = car.model;
    form.year.value = car.year;
    form.price.value = car.price;
    form.mileage.value = car.mileage;
    form.description.value = car.description || "";
    existingImageUrl = car.imageUrl || null;
    currentImage.src =
      existingImageUrl || "https://placehold.co/600x400?text=No+Image";
  };

  try {
    setLoading(true);
    const car = await getCar(carId);
    populateForm(car);
  } catch (error) {
    handleError(error);
    window.location.href = "index.html";
    return;
  } finally {
    setLoading(false);
  }

  const previewImage = (file) => {
    preview.innerHTML = "";
    if (!file) {
      const img = document.createElement("img");
      img.src =
        existingImageUrl || "https://placehold.co/600x400?text=No+Image";
      preview.appendChild(img);
      return;
    }
    const img = document.createElement("img");
    img.src = URL.createObjectURL(file);
    img.onload = () => URL.revokeObjectURL(img.src);
    preview.appendChild(img);
  };

  imageInput?.addEventListener("change", async (event) => {
    const file = event.target.files?.[0];
    previewImage(file);
    if (!file) {
      replacementImageUrl = null;
      return;
    }
    try {
      setLoading(true, "Uploading image...");
      replacementImageUrl = await uploadImage(file);
      showToast("Image uploaded");
    } catch (error) {
      replacementImageUrl = null;
      handleError(error);
    } finally {
      setLoading(false);
    }
  });

  form?.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }
    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());
    payload.year = Number(payload.year);
    payload.price = Number(payload.price);
    payload.mileage = Number(payload.mileage);
    payload.imageUrl = replacementImageUrl || existingImageUrl;
    try {
      setLoading(true, "Saving changes...");
      await updateCar(carId, payload);
      showToast("Car updated");
      window.location.href = `car-details.html?id=${carId}`;
    } catch (error) {
      handleError(error);
    } finally {
      setLoading(false);
    }
  });
};

// --- Router bootstrap ------------------------------------------------------
document.addEventListener("DOMContentLoaded", () => {
  const page = document.body.dataset.page;
  switch (page) {
    case "list":
      initListPage();
      break;
    case "add":
      initAddCarPage();
      break;
    case "details":
      initDetailsPage();
      break;
    case "edit":
      initEditPage();
      break;
    default:
      break;
  }
});

