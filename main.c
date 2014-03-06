#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "mpi.h" 
#include "parmetis.h"

int main(int argc, char *argv[])
{
    int mpi_rank, mpi_size;

    MPI_Init(&argc,&argv);

    MPI_Comm_size(MPI_COMM_WORLD,&mpi_size);
    MPI_Comm_rank(MPI_COMM_WORLD,&mpi_rank);

    idx_t vtxdist[4] = {0,4,8,12};

    idx_t *xadj;
    idx_t eptr0[5] = {0,1,3,5,7};
    idx_t eptr1[5] = {0,3,6,9,12};
    idx_t eptr2[5] = {0,2,4,6,7};
    if (mpi_rank==0) xadj = eptr0;
    if (mpi_rank==1) xadj = eptr1;
    if (mpi_rank==2) xadj = eptr2;

    idx_t *adjncy;
    idx_t eind0[7] = {6, 6,7, 7,8, 6,9};
    idx_t eind1[12] = {7,9,10, 8,10,11, 0,1,3, 1,2,4};
    idx_t eind2[7] = {2,5, 3,4, 4,5, 5};
    if (mpi_rank==0) adjncy = eind0;
    if (mpi_rank==1) adjncy = eind1;
    if (mpi_rank==2) adjncy = eind2;

    idx_t *vwgt = NULL;
    idx_t *adjwgt = NULL;
    idx_t wgtflag = 0;

    idx_t numflag = 0;
    idx_t ncon = 1;
    idx_t ncommonnodes = 2;
    idx_t nparts = 3;
    real_t tpwgts[3] = {1./3., 1./3., 1./3.};

    real_t ubvec[1] = {1.05};
    idx_t options[1] = {0};
    idx_t edgecut;

    idx_t *part;
    part = malloc(sizeof(real_t)*4);
    part = malloc(sizeof(real_t)*4);
    part = malloc(sizeof(real_t)*4);

    MPI_Comm comm = MPI_COMM_WORLD;

    int err = ParMETIS_V3_PartKway(vtxdist, xadj, adjncy, vwgt, adjwgt, &wgtflag,
                 &numflag, &ncon, &nparts, tpwgts, ubvec,
                 options, &edgecut, part, &comm);

    if (err==METIS_OK) {
        printf("ok\n");
    } else if (err==METIS_ERROR) {
        printf("error\n");
    }

    int iind;
    printf("rank: %d\n", mpi_rank);
    printf("part: ");
    for (iind = 0 ; iind < 4 ; iind++) {
        printf("%d ",part[iind]);
    }
    printf("\n");
    printf("edgecut: %d\n", edgecut);
    printf("\n");

    MPI_Finalize(); 

    return 0; 
}
