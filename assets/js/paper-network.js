(function () {
  function ready(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn);
    } else {
      fn();
    }
  }

  ready(function () {
    var root = document.querySelector("[data-paper-network]");
    if (!root) return;

    var dataElement = root.querySelector("#paper-network-data");
    var svg = root.querySelector(".paper-network-svg");
    var viewport = root.querySelector(".paper-network-viewport");
    if (!dataElement || !svg || !viewport) return;

    var data;
    try {
      data = JSON.parse(dataElement.textContent);
    } catch (error) {
      root.classList.add("paper-network-error");
      return;
    }

    var nodes = Array.isArray(data.nodes) ? data.nodes : [];
    var edges = Array.isArray(data.edges) ? data.edges : [];
    var nodeMap = new Map();
    nodes.forEach(function (node) {
      nodeMap.set(node.id, node);
    });

    var svgNamespace = "http://www.w3.org/2000/svg";
    var viewBox = { width: 900, height: 520 };
    var view = { x: 0, y: 0, scale: 1 };
    var activeId = null;
    var drag = null;

    var detail = {
      label: root.querySelector(".paper-network-detail-label"),
      title: root.querySelector(".paper-network-detail-title"),
      meta: root.querySelector(".paper-network-detail-meta"),
      authors: root.querySelector(".paper-network-detail-authors"),
      topics: root.querySelector(".paper-network-detail-topics"),
      anchor: root.querySelector(".paper-network-detail-anchor"),
      relatedList: root.querySelector(".paper-network-related-list"),
    };

    function createSvgElement(tagName, attributes) {
      var element = document.createElementNS(svgNamespace, tagName);
      Object.keys(attributes || {}).forEach(function (name) {
        element.setAttribute(name, attributes[name]);
      });
      return element;
    }

    function clamp(value, min, max) {
      return Math.max(min, Math.min(max, value));
    }

    function svgPoint(event) {
      var rect = svg.getBoundingClientRect();
      return {
        x: ((event.clientX - rect.left) / rect.width) * viewBox.width,
        y: ((event.clientY - rect.top) / rect.height) * viewBox.height,
      };
    }

    function applyTransform() {
      viewport.setAttribute("transform", "translate(" + view.x + " " + view.y + ") scale(" + view.scale + ")");
      root.classList.toggle("paper-network-is-zoomed", view.scale >= 1.35);
      var reset = root.querySelector('[data-network-zoom="reset"]');
      if (reset) reset.textContent = Math.round(view.scale * 100) + "%";
    }

    function setZoom(nextScale, origin) {
      var previousScale = view.scale;
      var scale = clamp(nextScale, 0.72, 2.6);
      if (scale === previousScale) return;

      var point = origin || { x: viewBox.width / 2, y: viewBox.height / 2 };
      view.x = point.x - ((point.x - view.x) * scale) / previousScale;
      view.y = point.y - ((point.y - view.y) * scale) / previousScale;
      view.scale = scale;
      applyTransform();
    }

    function resetView() {
      view.x = 0;
      view.y = 0;
      view.scale = 1;
      applyTransform();
    }

    function connectedIds(id) {
      var connected = new Set([id]);
      edges.forEach(function (edge) {
        if (edge.source === id) connected.add(edge.target);
        if (edge.target === id) connected.add(edge.source);
      });
      return connected;
    }

    function relatedEdges(id) {
      return edges.filter(function (edge) {
        return edge.source === id || edge.target === id;
      });
    }

    function clearHighlight() {
      root.querySelectorAll(".paper-network-node").forEach(function (node) {
        node.classList.remove("is-dimmed", "is-highlighted", "is-active");
      });
      root.querySelectorAll(".paper-network-edge").forEach(function (edge) {
        edge.classList.remove("is-dimmed", "is-highlighted");
      });
    }

    function highlight(id) {
      if (!id) {
        clearHighlight();
        return;
      }

      var connected = connectedIds(id);
      root.querySelectorAll(".paper-network-node").forEach(function (nodeElement) {
        var nodeId = nodeElement.getAttribute("data-paper-id");
        nodeElement.classList.toggle("is-active", nodeId === activeId);
        nodeElement.classList.toggle("is-highlighted", connected.has(nodeId));
        nodeElement.classList.toggle("is-dimmed", !connected.has(nodeId));
      });

      root.querySelectorAll(".paper-network-edge").forEach(function (edgeElement) {
        var source = edgeElement.getAttribute("data-source");
        var target = edgeElement.getAttribute("data-target");
        var isRelated = source === id || target === id;
        edgeElement.classList.toggle("is-highlighted", isRelated);
        edgeElement.classList.toggle("is-dimmed", !isRelated);
      });
    }

    function setText(element, value) {
      if (element) element.textContent = value || "";
    }

    function renderTopics(node) {
      if (!detail.topics) return;
      detail.topics.textContent = "";
      (node.topics || []).forEach(function (topic) {
        var chip = document.createElement("span");
        chip.className = "paper-network-topic";
        chip.textContent = topic;
        detail.topics.appendChild(chip);
      });
    }

    function renderRelated(node) {
      if (!detail.relatedList) return;
      detail.relatedList.textContent = "";

      relatedEdges(node.id).forEach(function (edge) {
        var otherId = edge.source === node.id ? edge.target : edge.source;
        var other = nodeMap.get(otherId);
        if (!other) return;

        var item = document.createElement("li");
        var code = document.createElement("span");
        var text = document.createElement("span");
        code.className = "paper-network-related-code";
        code.textContent = other.id;
        text.textContent = edge.relation;
        item.appendChild(code);
        item.appendChild(text);
        detail.relatedList.appendChild(item);
      });
    }

    function selectPaper(id) {
      var node = nodeMap.get(id);
      if (!node) return;

      activeId = id;
      setText(detail.label, node.id + " | " + node.kind);
      setText(detail.title, node.title);
      setText(detail.meta, node.status + ", " + node.year);
      setText(detail.authors, node.authors);
      renderTopics(node);
      renderRelated(node);

      if (detail.anchor) {
        detail.anchor.href = "#" + node.bibkey;
        detail.anchor.textContent = "View publication card";
      }

      highlight(id);
    }

    function drawEdges() {
      var edgeLayer = createSvgElement("g", { class: "paper-network-edges" });
      edges.forEach(function (edge) {
        var source = nodeMap.get(edge.source);
        var target = nodeMap.get(edge.target);
        if (!source || !target) return;

        var line = createSvgElement("line", {
          class: "paper-network-edge",
          x1: source.x,
          y1: source.y,
          x2: target.x,
          y2: target.y,
          "data-source": edge.source,
          "data-target": edge.target,
        });
        var title = createSvgElement("title", {});
        title.textContent = edge.relation;
        line.appendChild(title);
        edgeLayer.appendChild(line);
      });
      viewport.appendChild(edgeLayer);
    }

    function drawNodes() {
      var nodeLayer = createSvgElement("g", { class: "paper-network-nodes" });
      nodes.forEach(function (node) {
        var group = createSvgElement("g", {
          class: "paper-network-node",
          transform: "translate(" + node.x + " " + node.y + ")",
          tabindex: "0",
          role: "button",
          "aria-label": node.id + ": " + node.title,
          "data-paper-id": node.id,
        });

        var halo = createSvgElement("circle", { class: "paper-network-node-halo", r: "27" });
        var circle = createSvgElement("circle", { class: "paper-network-node-dot", r: "20" });
        var code = createSvgElement("text", {
          class: "paper-network-node-code",
          x: "0",
          y: "5",
          "text-anchor": "middle",
        });
        var title = createSvgElement("text", {
          class: "paper-network-title-label",
          x: "30",
          y: "5",
        });
        var accessibleTitle = createSvgElement("title", {});

        code.textContent = node.id;
        title.textContent = node.short_title;
        accessibleTitle.textContent = node.title;

        group.appendChild(accessibleTitle);
        group.appendChild(halo);
        group.appendChild(circle);
        group.appendChild(code);
        group.appendChild(title);

        group.addEventListener("mouseenter", function () {
          highlight(node.id);
        });
        group.addEventListener("mouseleave", function () {
          highlight(activeId);
        });
        group.addEventListener("click", function () {
          selectPaper(node.id);
        });
        group.addEventListener("keydown", function (event) {
          if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            selectPaper(node.id);
          }
        });

        nodeLayer.appendChild(group);
      });
      viewport.appendChild(nodeLayer);
    }

    function initializeControls() {
      root.querySelectorAll("[data-network-zoom]").forEach(function (button) {
        button.addEventListener("click", function () {
          var action = button.getAttribute("data-network-zoom");
          if (action === "in") setZoom(view.scale * 1.2);
          if (action === "out") setZoom(view.scale / 1.2);
          if (action === "reset") resetView();
        });
      });

      svg.addEventListener(
        "wheel",
        function (event) {
          event.preventDefault();
          var factor = event.deltaY > 0 ? 0.9 : 1.12;
          setZoom(view.scale * factor, svgPoint(event));
        },
        { passive: false }
      );

      svg.addEventListener("pointerdown", function (event) {
        drag = {
          pointerId: event.pointerId,
          startX: event.clientX,
          startY: event.clientY,
          x: view.x,
          y: view.y,
        };
        svg.setPointerCapture(event.pointerId);
        root.classList.add("is-dragging");
      });

      svg.addEventListener("pointermove", function (event) {
        if (!drag || drag.pointerId !== event.pointerId) return;
        var rect = svg.getBoundingClientRect();
        view.x = drag.x + ((event.clientX - drag.startX) / rect.width) * viewBox.width;
        view.y = drag.y + ((event.clientY - drag.startY) / rect.height) * viewBox.height;
        applyTransform();
      });

      function endDrag(event) {
        if (!drag || drag.pointerId !== event.pointerId) return;
        svg.releasePointerCapture(event.pointerId);
        drag = null;
        root.classList.remove("is-dragging");
      }

      svg.addEventListener("pointerup", endDrag);
      svg.addEventListener("pointercancel", endDrag);
    }

    drawEdges();
    drawNodes();
    initializeControls();
    selectPaper("J3");
    applyTransform();
  });
})();
