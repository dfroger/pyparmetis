%module pyparmetis

%{
#define SWIG_FILE_WITH_INIT
#include "parmetis.h"
%}

%include "mpi4py/mpi4py.i"
%mpi4py_typemap(Comm, MPI_Comm);

%include "numpy.i"

%init %{
    import_array();
%}

%ignore ParMETIS_V3_PartKway;

/* TODO: replace int* IN_ARRAY1 with idx_t* */
%apply (int* IN_ARRAY1, int DIM1) {(idx_t* vtxdist, int n_vtxdist)}
%apply (int* IN_ARRAY1, int DIM1) {(idx_t* xadj, int n_xadj)}
%apply (int* IN_ARRAY1, int DIM1) {(idx_t* adjncy, int n_adjncy)}
%apply (int* ARGOUT_ARRAY1, int DIM1) {(idx_t *part, int n_part)}

%inline %{

/* TODO: replace int nparts with idx_t nparts, etc*/
int ParMETIS_V3_PartKway_helper(
    idx_t *vtxdist, int n_vtxdist,
    idx_t *xadj, int n_xadj,
    idx_t *adjncy, int n_adjncy,
    int nparts,
    MPI_Comm comm,
    idx_t *part, int n_part
)
{
    int mpi_rank, mpi_size;

    MPI_Comm_size(comm,&mpi_size);
    MPI_Comm_rank(comm,&mpi_rank);

    idx_t *vwgt = NULL;
    idx_t *adjwgt = NULL;
    idx_t wgtflag = 0;

    idx_t numflag = 0;
    idx_t ncon = 1;
    idx_t ncommonnodes = 2;
    real_t *tpwgts = malloc( sizeof(real_t) * ncon*nparts);
    int i;
    for (i=0 ; i<ncon*nparts ; i++)
        tpwgts[i] = 1. / (ncon*nparts);

    real_t ubvec[1] = {1.05};
    idx_t options[1] = {0};
    idx_t edgecut;

    int err = ParMETIS_V3_PartKway(vtxdist, xadj, adjncy, vwgt, adjwgt, &wgtflag,
                   &numflag, &ncon, &nparts, tpwgts, ubvec,
                   options, &edgecut, part, &comm);
    if (err==METIS_ERROR) {
        return -1;
    } else {
        return edgecut;
    }
}

%}

%pythoncode %{
def ParMETIS_V3_PartKway(vtxdist, xadj, adjncy, nparts, comm):
    n_part = len(xadj)-1
    edgecut, part = ParMETIS_V3_PartKway_helper(vtxdist, xadj, adjncy, nparts, comm, n_part)
    if edgecut==-1:
        raise RuntimeError, "ParMETIS internal error"
    return edgecut, part
%}


%include "parmetis.h"
