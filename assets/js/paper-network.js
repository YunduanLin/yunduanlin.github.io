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

    var graphData;
    try {
      graphData = JSON.parse(dataElement.textContent);
    } catch (error) {
      root.classList.add("paper-network-error");
      return;
    }

    var nodes = Array.isArray(graphData.nodes) ? graphData.nodes : [];
    var featureGroups = [
      { key: "concepts", label: "Concept", plural: "Concepts" },
      { key: "methods", label: "Method", plural: "Methods" },
      { key: "domains", label: "Domain", plural: "Domains" },
      { key: "data", label: "Data", plural: "Data" },
    ];
    var edgeClassNames = {
      concepts: "paper-network-edge-concepts",
      methods: "paper-network-edge-methods",
      domains: "paper-network-edge-domains",
      data: "paper-network-edge-data",
    };
    var edges = deriveSimilarityEdges(nodes);
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
      features: root.querySelector(".paper-network-detail-features"),
      anchor: root.querySelector(".paper-network-detail-anchor"),
    };

    var linkCount = root.querySelector("[data-network-link-count]");
    if (linkCount) linkCount.textContent = edges.length;

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

    function normalizeFeature(value) {
      return String(value || "")
        .trim()
        .toLowerCase()
        .replace(/\s+/g, " ");
    }

    function getFeatures(node, groupKey) {
      if (node.features && Array.isArray(node.features[groupKey])) {
        return node.features[groupKey].filter(Boolean);
      }

      if (groupKey === "concepts" && Array.isArray(node.topics)) {
        return node.topics.filter(Boolean);
      }

      return [];
    }

    function sharedFeatures(source, target, groupKey) {
      var sourceFeatures = getFeatures(source, groupKey);
      var targetLookup = new Set(getFeatures(target, groupKey).map(normalizeFeature));

      return sourceFeatures.filter(function (feature) {
        return targetLookup.has(normalizeFeature(feature));
      });
    }

    function pairKey(sourceId, targetId) {
      return sourceId < targetId ? sourceId + "::" + targetId : targetId + "::" + sourceId;
    }

    function deriveSimilarityEdges(papers) {
      var derived = [];

      for (var i = 0; i < papers.length; i += 1) {
        for (var j = i + 1; j < papers.length; j += 1) {
          featureGroups.forEach(function (group) {
            var shared = sharedFeatures(papers[i], papers[j], group.key);
            if (shared.length === 0) return;

            derived.push({
              source: papers[i].id,
              target: papers[j].id,
              type: group.key,
              label: group.label,
              shared: shared,
              relation: "Shared " + group.label.toLowerCase() + ": " + shared.join(", "),
            });
          });
        }
      }

      var grouped = new Map();
      derived.forEach(function (edge) {
        var key = pairKey(edge.source, edge.target);
        if (!grouped.has(key)) grouped.set(key, []);
        grouped.get(key).push(edge);
      });

      grouped.forEach(function (parallelEdges) {
        parallelEdges.forEach(function (edge, index) {
          edge.parallelIndex = index;
          edge.parallelCount = parallelEdges.length;
        });
      });

      return derived;
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
      root.classList.toggle("paper-network-is-zoomed", view.scale >= 1.18);
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

    function renderFeatures(node) {
      if (!detail.features) return;
      detail.features.textContent = "";

      featureGroups.forEach(function (group) {
        var values = getFeatures(node, group.key);
        if (values.length === 0) return;

        var wrapper = document.createElement("div");
        wrapper.className = "paper-network-feature-group paper-network-feature-group-" + group.key;

        var label = document.createElement("span");
        label.className = "paper-network-feature-label";
        label.textContent = group.plural;

        var list = document.createElement("span");
        list.className = "paper-network-feature-list";
        values.forEach(function (value) {
          var chip = document.createElement("span");
          chip.className = "paper-network-topic paper-network-feature paper-network-feature-" + group.key;
          chip.textContent = value;
          list.appendChild(chip);
        });

        wrapper.appendChild(label);
        wrapper.appendChild(list);
        detail.features.appendChild(wrapper);
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
      renderFeatures(node);

      if (detail.anchor) {
        detail.anchor.href = "#" + node.bibkey;
        detail.anchor.textContent = "View publication card";
      }

      highlight(id);
    }

    function edgeWidth(edge) {
      var count = Math.min(edge.shared.length, 3);
      return String(1.6 + (count - 1) * 1.1);
    }

    function edgePath(source, target, edge) {
      var dx = target.x - source.x;
      var dy = target.y - source.y;
      var distance = Math.sqrt(dx * dx + dy * dy) || 1;
      var normalX = -dy / distance;
      var normalY = dx / distance;
      var offset = (edge.parallelIndex - (edge.parallelCount - 1) / 2) * 15;
      var controlX = (source.x + target.x) / 2 + normalX * offset;
      var controlY = (source.y + target.y) / 2 + normalY * offset;

      return "M " + source.x + " " + source.y + " Q " + controlX + " " + controlY + " " + target.x + " " + target.y;
    }

    function drawEdges() {
      var edgeLayer = viewport.querySelector(".paper-network-edges");
      if (!edgeLayer) {
        edgeLayer = createSvgElement("g", { class: "paper-network-edges" });
        viewport.appendChild(edgeLayer);
      }
      edgeLayer.textContent = "";

      edges.forEach(function (edge) {
        var source = nodeMap.get(edge.source);
        var target = nodeMap.get(edge.target);
        if (!source || !target) return;

        var path = createSvgElement("path", {
          class: "paper-network-edge " + edgeClassNames[edge.type],
          d: edgePath(source, target, edge),
          "stroke-width": edgeWidth(edge),
          "data-source": edge.source,
          "data-target": edge.target,
          "data-feature-type": edge.type,
          "data-shared-count": edge.shared.length,
        });
        var title = createSvgElement("title", {});
        title.textContent = edge.source + " - " + edge.target + ": " + edge.relation;
        path.appendChild(title);
        edgeLayer.appendChild(path);
      });
    }

    function drawNodes() {
      var nodeLayer = viewport.querySelector(".paper-network-nodes");
      if (!nodeLayer) {
        nodeLayer = createSvgElement("g", { class: "paper-network-nodes" });
        viewport.appendChild(nodeLayer);
      }
      nodeLayer.textContent = "";

      nodes.forEach(function (node) {
        var group = createSvgElement("g", {
          class: "paper-network-node",
          transform: "translate(" + node.x + " " + node.y + ")",
          tabindex: "0",
          role: "button",
          "aria-label": node.id + ": " + node.title,
          "data-paper-id": node.id,
        });

        var halo = createSvgElement("circle", { class: "paper-network-node-halo", r: "31" });
        var circle = createSvgElement("circle", { class: "paper-network-node-dot", r: "23" });
        var code = createSvgElement("text", {
          class: "paper-network-node-code",
          x: "0",
          y: "5",
          "text-anchor": "middle",
        });
        var isRightEdgeNode = node.x >= 700;
        var title = createSvgElement("text", {
          class: "paper-network-title-label",
          x: isRightEdgeNode ? "-34" : "34",
          y: "5",
          "text-anchor": isRightEdgeNode ? "end" : "start",
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
        if (event.target.closest(".paper-network-node")) return;

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
