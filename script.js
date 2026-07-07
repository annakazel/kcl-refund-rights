document.querySelectorAll("[data-copy]").forEach((button) => {
  button.addEventListener("click", async () => {
    const id = button.getAttribute("data-copy");
    const text = document.getElementById(id)?.innerText.trim();
    if (!text) return;
    await navigator.clipboard.writeText(text);
    const original = button.innerText;
    button.innerText = "Copied";
    setTimeout(() => {
      button.innerText = original;
    }, 1400);
  });
});
