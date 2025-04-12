</div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/admin.js"></script>

    <!-- Additional scripts based on page needs -->
    <c:if test="${param.scripts != null}">
        <c:forEach var="script" items="${param.scripts}">
            <script src="${pageContext.request.contextPath}/assets/js/${script}.js"></script>
        </c:forEach>
    </c:if>

    <!-- Include Chart.js if needed -->
    <c:if test="${param.useCharts == 'true'}">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    </c:if>
</body>
</html>